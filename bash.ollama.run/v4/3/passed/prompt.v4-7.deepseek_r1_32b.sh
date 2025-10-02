#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let me go through the requirements step by step.
#
#First, the script should activate only when the user types `ollama run` and presses TAB. So, I'll check if the second word in the command is exactly 'run'. That means looking at `${COMP_WORDS[1]}`.
#
#Next, I need to get the list of models from `ollama list`. The output has headers, so I should skip the first line. Using `awk` or `cut` seems reliable. Maybe `awk '{print $1}'` will extract just the model names after skipping the header.
#
#I'll store these models in an array. Then, I need to filter this array based on what the user is typing. For example, if they type 'co', only show models starting with 'co'. Using a loop and checking each model against the current word makes sense here.
#
#Also, I must avoid duplicates. Since `ollama list` probably doesn't have duplicates, but it's safer to ensure each suggestion is unique by not adding them multiple times.
#
#I should never suggest filenames if there are no matching models. So, if after filtering the array is empty, do nothing. No fallbacks here.
#
#The script needs to use standard Bash variables like `COMP_WORDS`, `COMP_CWORD`, and `COMPREPLY`. I'll structure the completion function correctly, using `_ollama_run_completion` as a helper.
#
#Putting it all together: The function will check if the command is 'run', fetch models, filter them, and set `COMPREPLY` with the matches. Then, register this function in the completion setup for `ollama`.
#
#Testing edge cases: If no models match, nothing should happen. Also, ensure that only the correct word position triggers the completion.
#
#I think I've covered all the requirements without falling into common mistakes like suggesting wrong parts of output or using non-standard functions.
#...done thinking.

# Bash completion script for ollama run command
# This script provides autocompletion for model names when using 'ollama run'

_ollama_run_completion() {
    local cur prev words cword
    # Split the command into words and get the current word position
    words=(${COMP_WORDS[@]})
    cword=$COMP_CWORD

    # Only trigger completion for the word immediately after 'run'
    if [[ ${words[1]} != "run" ]]; then
        return 0
    fi

    # Get the current word being completed
    cur="${words[cword]}"

    # Fetch list of available models from ollama list, skipping header and extracting first column
    local models=()
    while read -r line; do
        if [[ "$line" == "NAME"* ]]; then
            continue  # Skip the header line
        fi
        model_name=$(echo "$line" | awk '{print $1}')
        models+=("$model_name")
    done < <(ollama list)

    # Filter models based on current input
    local suggestions=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            suggestions+=("$model")
        fi
    done

    # Set the completions, ensuring no duplicates and only model names are suggested
    COMPREPLY=($(printf "%s\n" "${suggestions[@]}" | sort -u))

    return 0
}

# Register completion function for 'ollama run'
complete -F _ollama_run_completion ollama


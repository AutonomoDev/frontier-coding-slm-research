#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses the tab key. Let me break down the requirements and think through how to approach this.
#
#First, the script must only activate when the second word is exactly 'run'. So I'll check if `${COMP_WORDS[1]}` equals 'run'. That makes sense because we don't want it triggering for other subcommands or the main command itself.
#
#Next, I need to get the list of available models from `ollama list`. The output has headers and model details. I must extract only the first column, which are the model names. Using `awk '{print $1}'` seems reliable. Also, I should skip the header line starting with 'NAME'. So, I'll pipe the output to `grep -v '^NAME'` before extracting the first column.
#
#Parsing this output correctly is crucial. I can use a while loop to read each model name and add them to an array. This way, I avoid any issues with spaces or special characters in the model names because each line is treated as a single entry.
#
#Now, handling the current word being typed. The variable `COMP_WORDS[COMP_CWORD]` gives the current word. I need to filter the models that start with this string. Using `grep "^${cur}"` on each model name will do this. But I have to handle cases where `cur` is empty (when the user hasn't typed anything after 'run'), in which case all models should be suggested.
#
#Duplicates must be avoided, so using an associative array to track seen model names can help ensure uniqueness. This way, even if there are duplicates in the output from `ollama list`, they won't appear twice in the suggestions.
#
#I also need to avoid falling back to filename completion if no matches are found. So, I shouldn't include any fallback logic beyond just setting COMPREPLY appropriately based on the models available.
#
#Putting it all together: The script will check the context (whether the command is 'run'), fetch and parse the model list, filter them based on the current input, remove duplicates, and set the completions accordingly. All within standard Bash syntax without any external dependencies beyond what's provided by `ollama`.
#
#Testing edge cases like no matches or partial matches is important to ensure the script behaves correctly in all scenarios. For example, if the user types something that doesn't match any model, no suggestions should appear.
#
#Finally, I'll structure the script with comments for clarity, making it easy to understand and maintain.
#...done thinking.

# Bash completion script for ollama run command

_ollama_run_completion() {
    local cur prev words cword
    # Extract current word being completed and previous word
    _get_comp_words_by_ref -n : cur prev <<< "$COMP_LINE"

    # Check if the second word is exactly 'run' to trigger completion
    if [ "${COMP_WORDS[1]}" == "run" ]; then
        # Get model list from ollama list, skipping header and extracting first column
        local models=$(ollama list 2>/dev/null | grep -v '^NAME' | awk '{print $1}')

        # Split models into an array for processing
        local IFS=$'\n'
        local model_list=($models)

        # Filter models based on current input (cur)
        COMPREPLY=()
        while read -r model; do
            if [[ "$model" == "$cur"* ]]; then
                # Use associative array to avoid duplicates
                COMPREPLY["$model"]=1
            fi
        done <<< "${model_list[@]}"

        # Convert associative array keys back into an indexed array
        local i=0
        for key in "${!COMPREPLY[@]}"; do
            COMPREPLY[$i]="$key"
            ((i++))
        done

        # Remove duplicates and sort the results
        # (Using an associative array already ensures uniqueness)
    fi

    return 0
}

# Register completion function with bash-completion framework
complete -F _ollama_run_completion ollama

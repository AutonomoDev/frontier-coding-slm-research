#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses Tab.
#
#First, I should understand how Bash completions work. They use functions that are triggered when the user presses Tab. These functions look at the current command line and generate possible completions.
#
#The core requirement is that the completion only activates after `run`. So, the script must check if the first word is `ollama` and the previous word is exactly `run`.
#
#Next, I need to get the list of models from `ollama list`. The output has a header line starting with "NAME", followed by model names in the first column. I'll use `cut` to extract just the model names, skipping the header.
#
#For parsing, I can pipe `ollama list` to `tail -n +2` to skip the header, then use `cut -d$'\t' -f1` to get the first column. This handles model names with colons correctly because we're using tabs as delimiters.
#
#When the user starts typing, like `ollama run co<TAB>`, the script should filter models starting with "co". So, I'll compare each model name against the current word being typed (`cur` variable) to find matches.
#
#I must ensure that only model names are suggested and not fallback to filenames. So, after filtering, if there are no matches, nothing is added to `COMPREPLY`.
#
#Also, the suggestions should be unique. Since `ollama list` shouldn't have duplicates, maybe I don't need to deduplicate, but it's safer to include a step just in case.
#
#I'll structure the script with a function `_ollama_run_completion` that checks if the command is `ollama run`, then fetches and processes the model names. It will filter them based on what the user has typed so far.
#
#Testing for edge cases: If the current word doesn't match any model, nothing should be suggested. Also, handle cases where `ollama list` might not return anything or returns an error.
#
#I need to use standard Bash variables like `COMP_WORDS`, `COMP_CWORD`, and set `COMPREPLY`. The function will be added to the completion system using `complete -F`.
#
#Putting it all together, I'll write a script that sources into the user's shell. It uses `_get_comp_words_by_ref` with a fallback to handle older systems. The model list is fetched each time to ensure up-to-date suggestions.
#
#Finally, I'll make sure the script doesn't have any syntax errors and adheres to all the requirements, including no filename fallbacks and correct handling of colons in model names.
#...done thinking.

# Bash completion script for `ollama run` command
# Provides autocompletion for model names based on `ollama list`

complete_ollama_run() {
    # Check if command starts with 'ollama' and previous word is exactly 'run'
    local command="${COMP_WORDS[0]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ "$command" != "ollama" ]] || [[ "$prev" != "run" ]]; then
        return  # Only complete for `ollama run`
    fi

    # Extract model names from `ollama list` output
    local models=$(ollama list 2>/dev/null | \
        tail -n +2 | \
        cut -d$'\t' -f1)

    # Get the current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Filter models that start with the current word
    COMPREPLY=()
    while IFS=$'\n' read -r model; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done <<< "$models"

    # Return without suggesting filenames or other completions
    return 0
}

# Register the completion function for 'run'
complete -F complete_ollama_run ollama


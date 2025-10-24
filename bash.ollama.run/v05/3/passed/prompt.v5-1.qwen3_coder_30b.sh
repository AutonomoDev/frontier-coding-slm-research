# Bash completion script for `ollama run` command
# This script provides autocompletion for model names after `ollama run`
# It parses the output of `ollama list` to extract model names
# and filters them based on the current input being completed.

# Function to perform completion for ollama run command
_ollama_run_completion() {
    # Check if we are completing the word after 'run'
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Get the current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Initialize an empty array for completions
    local completions=()

    # Get list of models from ollama, skip header line, extract first column
    # Use awk to parse the output, skip header line, and get first field
    local model_list
    model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Loop through each model name and check if it matches current input
    for model in $model_list; do
        # If model name starts with current input, add to completions
        if [[ "$model" == "$cur"* ]]; then
            completions+=("$model")
        fi
    done

    # Remove duplicates by converting to associative array and back
    local unique_completions=()
    declare -A seen
    for item in "${completions[@]}"; do
        if [[ -z "${seen[$item]}" ]]; then
            seen[$item]=1
            unique_completions+=("$item")
        fi
    done

    # Set the completion replies
    COMPREPLY=("${unique_completions[@]}")
}

# Register the completion function for the ollama command
complete -F _ollama_run_completion ollama


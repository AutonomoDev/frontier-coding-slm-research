# Bash completion script for `ollama run` command
# This script provides autocompletion for model names when using `ollama run`

# Function to generate completions for ollama run
_ollama_run_completion() {
    # Only activate for the word immediately after 'run'
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Get the current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Initialize COMPREPLY array
    COMPREPLY=()

    # Get list of models, skip header, extract first column (model names)
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)

    # If no models found, return early
    if [[ -z "$models" ]]; then
        return 0
    fi

    # Filter models based on current input
    local filtered_models
    filtered_models=$(printf '%s\n' "$models" | grep "^$cur")

    # If there are matching models, add them to COMPREPLY
    if [[ -n "$filtered_models" ]]; then
        COMPREPLY=($(printf '%s\n' "$filtered_models"))
    fi
}

# Register the completion function for ollama command
complete -F _ollama_run_completion ollama


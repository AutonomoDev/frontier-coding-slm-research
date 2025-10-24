# Bash completion script for `ollama run` command
# This script provides autocompletion for model names after `ollama run`

# Function to generate completions for ollama run
_ollama_run_completion() {
    # Only activate when the second word is exactly "run"
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

    # Filter models based on current input
    if [[ -n "$cur" ]]; then
        # Use printf to filter and build COMPREPLY
        while IFS= read -r model; do
            if [[ "$model" == "$cur"* ]]; then
                COMPREPLY+=("$model")
            fi
        done <<< "$models"
    else
        # No prefix, return all models
        while IFS= read -r model; do
            COMPREPLY+=("$model")
        done <<< "$models"
    fi

    # Ensure no duplicates in reply
    if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
        COMPREPLY=($(printf '%s\n' "${COMPREPLY[@]}" | sort -u))
    fi
}

# Register the completion function for ollama command
complete -F _ollama_run_completion ollama


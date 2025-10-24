# Bash completion script for `ollama run` command
# This script provides autocompletion for model names when using `ollama run`

# Function to get current word being completed and previous word
# Fallback for _get_comp_words_by_ref if not available
_get_comp_words_by_ref_fallback() {
    local cur prev words cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
}

# Main completion function for ollama
_ollama_completion() {
    local cur prev words cword
    # Use _get_comp_words_by_ref if available, otherwise fallback
    if ! command -v _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref_fallback
    else
        _get_comp_words_by_ref -n : cur prev
    fi

    # Only complete when we are directly after 'ollama run'
    if [[ "${COMP_WORDS[0]}" == "ollama" && "${prev}" == "run" ]]; then
        # Get list of models from ollama list, skip header line, extract first column
        local models
        models=$(ollama list 2>/dev/null | sed '1d' | cut -f1 | sort | uniq)

        # Filter models based on current input
        if [[ -n "$cur" ]]; then
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
        else
            # If no input, show all models
            COMPREPLY=($(compgen -W "$models"))
        fi
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completion ollama


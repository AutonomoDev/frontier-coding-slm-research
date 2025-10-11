# Bash completion script for `ollama run` command
# This script provides autocompletion for model names from `ollama list`

# Function to generate completions for ollama run
_ollama_run_completion() {
    # Get current and previous words
    local cur prev words cword
    # Fallback for _get_comp_words_by_ref if not available
    if ! command -v _get_comp_words_by_ref >/dev/null 2>&1; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    else
        _get_comp_words_by_ref -n : cur prev
    fi

    # Only complete when the command is `ollama run`
    if [[ "${COMP_WORDS[0]}" == "ollama" && "${prev}" == "run" ]]; then
        # Get the list of models, skip header, extract first column
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | cut -d' ' -f1 | sort | uniq)
        
        # If no models, return early
        if [[ -z "$models" ]]; then
            return
        fi

        # Filter models based on current input
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function for ollama
complete -F _ollama_run_completion ollama



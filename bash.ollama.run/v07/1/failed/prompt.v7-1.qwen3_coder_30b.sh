# Function to provide completion for 'ollama run' command
_ollama_run_completion() {
    local cur prev words cword
    local run_index
    local old_wb

    # Use _get_comp_words_by_ref if available, otherwise fallback
    if ! _get_comp_words_by_ref -n : cur prev words cword; then
        # Fallback implementation
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Find the index of 'run' in COMP_WORDS
    for i in "${!words[@]}"; do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete if we're directly after 'run'
    if [[ $cword -ne $((run_index + 1)) ]]; then
        return 0
    fi

    # Save current COMP_WORDBREAKS and remove colon
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get list of models from 'ollama list', extract first column (names)
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Restore COMP_WORDBREAKS before any return
    COMP_WORDBREAKS=$old_wb

    # If no models found, exit quietly
    if [[ -z "$models" ]]; then
        return 0
    fi

    # Generate completions based on current input
    compgen -W "$models" -- "$cur" | while read -r model; do
        COMPREPLY+=("$model")
    done

    # Avoid adding space after completion
    compopt -o nospace 2>/dev/null
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completion ollama


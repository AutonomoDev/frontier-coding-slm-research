_ollama_completions() {
    # Ensure the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch models from 'ollama list'
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi
    
    # Generate completions based on current word (with possible colon prefix)
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort the completion list to ensure alphabetical order
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    
    # Trim colon from completions for consistency when completing after colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function with 'ollama'
complete -F _ollama_completions ollama

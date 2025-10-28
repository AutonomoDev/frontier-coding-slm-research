```bash
_ollama_completions() {
    # Ensure completion is for 'ollama run' and the model argument is the third word
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi
    if [[ $COMP_CWORD -ne 2 ]]; then
        return 0
    fi

    local cur prev models=()

    # Handle colons in completion (e.g., 'codellama:')
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Fetch models from 'ollama list' command, skipping header and parsing names only
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    else
        return 0
    fi

    # Sort models alphabetically to ensure consistent completion order
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS

    # Generate completions based on current word (cur)
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim colon from completion if needed
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
```


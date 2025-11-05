```bash
_ollama_completions() {
    # Validate that the command is 'ollama' followed by a subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" ]] && return
    local subcommands=(serve create show run stop pull push signin signout list ps cp rm help)
    if ! [[ " ${subcommands[@]} " =~ " ${COMP_WORDS[1]} " ]]; then
        COMPREPLY=()
        return
    fi

    # Extract current and previous word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fetch models using 'ollama list'
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions based on current word and models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort and trim colon prefixes for completion candidates
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


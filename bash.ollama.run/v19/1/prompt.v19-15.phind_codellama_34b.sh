```bash
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    local cur prev models
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then COMPREPLY=(); return; fi

    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


```bash
_ollama_completions() {
    # Correct index check
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Colons: local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then _get_comp_words_by_ref -n : cur prev; else cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"; fi

    # Parse: local models=()
    local models=()
    if command -v ollama &>/dev/null; then models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')); fi

    # Completions: sort and compgen
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Fix Colons: __ltrim_colon_completions last
    if type __ltrim_colon_completions &>/dev/null; then __ltrim_colon_completions "$cur"; fi
}

# Register completion function
complete -F _ollama_completions ollama
```


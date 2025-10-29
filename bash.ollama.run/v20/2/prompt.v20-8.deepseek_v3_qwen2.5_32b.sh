```bash
_ollama_completions() {
    # Validate that the command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Fetch models from ollama list, skip if not installed or no models found
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completions and sort them
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
    
    # Trim colons for cases like 'codellama:'
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


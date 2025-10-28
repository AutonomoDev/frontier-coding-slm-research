 ```bash
function _ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=();
        return;
    fi
    
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models are found, return empty
    if [ -z "$models" ]; then
        COMPREPLY=();
        return;
    fi
    
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort the completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    
    # Remove leading colon from completions if present
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


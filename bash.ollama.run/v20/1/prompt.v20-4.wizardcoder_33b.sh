```bash
_ollama_completions() {
    # Verify command prefix, return if not matching
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    # Extract current word under cursor
    local cur prev
    _get_comp_words_by_ref -n : cur
  
    # Fetch models, if ollama command not available, returns safely
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completions using the current word and available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
  
    # Sort and trim
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
``` 


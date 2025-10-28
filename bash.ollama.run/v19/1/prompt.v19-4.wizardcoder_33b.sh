```bash
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    local cur prev
    # Handle colons, set cur and prev correctly
    _get_comp_words_by_ref -n : cur prev
    
    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    
    # Parse models as a scalar string, not an array
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Handle no models case
    if [ -z "$models" ]; then COMPREPLY=(); return; fi
    
    # Generate completions with compgen, wrap in (()) to make array
    COMPREPLY=($(compgen -W  "$models" -- "$cur"))
    
    # Sort the COMPREPLY array after compgen
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    
    # Trim prefix from COMPREPLY elements with __ltrim_colon_completions
    __ltrim_colon_completions "$cur"
}

# Register function as completion for the 'ollama run' command
complete -F _ollama_completions ollama
``` 


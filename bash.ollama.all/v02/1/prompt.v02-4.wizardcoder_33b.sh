
```bash
# Main Function
_ollama_completions() {
    # Extract Word Info
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Top-Level Completion
    if [[ ${prev} == ollama ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
        return 0
    fi
    
    # Commands requiring <MODEL> completion
    if [[ ${prev} == show || ${prev} == run || ${prev} == stop || ${prev} == push || ${prev} == cp || ${prev} == rm ]]; then
        # Fetch models
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return 0; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        
        # Handle empty model list
        [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
        
        # Generate Completions
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        
        # Sort and Trim
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        return 0
    fi
    
    # Command with special flag completion
    if [[ ${prev} == create ]]; then
        COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
        return 0
    fi
    
    # Commands with no argument completion
    if [[ ${prev} == serve || ${prev} == pull || ${prev} == signin || ${prev} == signout || ${prev} == list || ${prev} == ps || ${prev} == help ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Fallback
    COMPREPLY=()
}

# Register the completion function
complete -F _ollama_completions ollama
``` 


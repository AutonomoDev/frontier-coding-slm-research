```bash
# Main Function
_ollama_completions() {
    # Extract Word Info
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Commands requiring model name completion
    case "$prev" in
        show|run|stop|push|cp|rm)
            # Fetch models and handle missing `ollama` command or empty model list
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Generate completions, sort and trim
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
        ;;
        
        # Command with special flag completion
        create)
            local flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
        ;;
        
        # Commands with no argument completion
        serve|pull|signin|signout|list|ps|help)
            COMPREPLY=()
        ;;
    esac
    
    # Top-Level Completion
    if [[ "${COMP_WORDS[1]}" == "" ]]; then
        local commands="show run stop push cp rm create serve pull signin signout list ps help"
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    fi
}

# Register the completion function
complete -F _ollama_completions ollama
``` 


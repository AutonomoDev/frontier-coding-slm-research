```bash
_ollama_completions() {
    # Check if previous word is 'ollama' (top-level command)
    if [ "${#COMP_WORDS[@]}" -gt 2 ] && [ "${COMP_WORDS[0]}" = "ollama" ]; then
        local cur prev
        _get_comp_words_by_ref -n : cur prev

        # Provide completions for all subcommands (excluding flags)
        if [ "$prev" = "ollama" ] && [[ ! ${COMPREPLY[@]} =~ .*=.* ]]; then
            COMPREPLY=($(compgen -W "show run stop pull cp rm create serve start signin signout list ls ps help" -- "$cur"))
        fi
    else
        local cur prev
        _get_comp_words_by_ref  -n : cur prev
        
        # Handle each subcommand separately with their completion logic
        case ${prev} in
            create|push|cp|rm)
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                ;;
            run|show)
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                ;;
            stop)
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                ;;
            pull|serve|start|signin|signout|list|ls|ps|help)
                # No model name completion for these commands
                COMPREPLY=()
                ;;
        esac
    fi
    
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
``` 


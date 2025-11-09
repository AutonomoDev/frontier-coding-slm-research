_ollama_completions() {
    local cur prev cmd flags args opts
    COMPREPLY=()
    
    # Get current and previous word (cur and prev) for completion logic
    _get_comp_words_by_ref -n : cur prev
    
    case "$prev" in
        ollama)
            # Top-level completions: list all subcommands
            COMPREPLY=( $(compgen -W "create pull serve start stop show run push cp rm signin signout list ls ps help" -- "$cur") )
            ;;
        
        create|pull|run|show) 
            # For commands with flags after model, no completion for model or flags here
            ;;
        
        stop)
            # Fetch running models via 'ollama ps' for completion
            local running_models
            if ! command -v ollama &>/dev/null; then return 0; fi
            running_models=$(ollama ps 2>/dev/null | tail -n +1 | awk '{print $1}')
            [[ -z "$running_models" ]] && { COMPREPLY=(); return 0; }
            COMPREPLY=( $(compgen -W "$running_models" -- "$cur") )
            ;;
        
        # Completion for model names (commands in Group 1)
        show|run|stop|push|cp|rm) 
            if [[ $prev == *ollama ]]; then
                # For commands requiring model completion, fetch models
                local models
                if ! command -v ollama &>/dev/null; then return 0; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                # Ensure sorted and ltrim colon completions
                COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
                __ltrim_colon_completions "$cur"
            fi
            ;;
        
        *)
            case "$prev" in 
                create)
                    # Flags for 'create' command after model
                    opts="--file -f --quantize -q"
                    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
                    ;;
                
                pull)
                    # Flag for 'pull' command after model
                    opts="--insecure"
                    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
                    ;;
                
                run)
                    # Flags for 'run' command after model
                    opts="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
                    ;;
                
                show)
                    # Flags for 'show' command after model
                    opts="--license --modefile --parameters --system --template --verbose"
                    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
                    ;;
            
                *)
                    # Other subcommands (serve, start, etc.) have no arguments
                    ;;
            esac
    esac
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama


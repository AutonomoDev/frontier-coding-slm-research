_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword

    case "${words[1]}" in
        # Top-level completion rule: if first word is 'ollama', complete subcommands
        ollama)
            COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
            return
            ;;

        # Group 1 commands with model completion (excluding stop)
        show|run|cp|rm|push)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

            # Fetch models
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Generate completion
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Sort and trim colon completions
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # Special stop model completion using `ollama ps`
        stop)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

            # Fetch models from 'ps'
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Generate completion
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Sort and trim colon completions
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return
            ;;

        # Group 2 commands with flags
        create)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            if [[ $cword -eq 2 ]]; then
                # Fetch models for 'create' first
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                # Generate model completion
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                
                # Sort and trim colon completions
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cur == -* ]]; then
                # Provide flags for 'create'
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi
            return
            ;;

        pull)
            if [[ $cur == -* ]]; then
                # Provide flags for 'pull'
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            fi
            return
            ;;

        run|show)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            if [[ $cword -eq 2 ]]; then
                # Fetch models for 'run' and 'show'
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                # Generate model completion
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                
                # Sort and trim colon completions
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cur == -* ]]; then
                if [[ ${words[1]} == "run" ]]; then
                    # Provide flags for 'run'
                    COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                elif [[ ${words[1]} == "show" ]]; then
                    # Provide flags for 'show'
                    COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                fi
            fi
            return
            ;;

        # Group 3 commands with no argument completion
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;
    esac
}

complete -F _ollama_completions ollama

```bash
_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword

    # Extract the subcommand
    local subcmd="${words[1]}"

    case "$subcmd" in
        show|run|stop|push|cp|rm)
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            # Step B — Fetch Models (Special for 'stop')
            if [[ "$subcmd" == "stop" ]]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi

            # Ensure models is not empty
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C — Generate
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D — Sort + Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;

        create)
            # Model completion first for 'create'
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Generate model completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
                # If no models matched, complete flags
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        pull)
            # Only flags for 'pull'
            if [[ $cword -eq 2 && "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            fi
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        run)
            # Model completion first for 'run'
            if [[ $cword -eq 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                # Generate model completions
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            else
                # Flags for 'run'
                if [[ $cword -gt 2 && "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                fi
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        show)
            # Model completion first for 'show'
            if [[ $cword -eq 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                # Generate model completions
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            else
                # Flags for 'show'
                if [[ $cword -gt 2 && "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                fi
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;

        serve|start|signin|signout|list|ls|ps|help)
            # No argument completion for these commands
            COMPREPLY=()
            return
            
            ;;
        
        *)
            # Top-level completion: subcommands only
            if [[ $cword -eq 1 ]]; then
                COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
            fi
            __ltrim_colon_completions "$cur"
            return

            ;;
    esac
}

complete -F _ollama_completions ollama
```


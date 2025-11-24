_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword

    local subcmd="${words[1]}"

    case "$subcmd" in
        show|run|stop|push|cp|rm)
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            if [[ "$subcmd" == "stop" ]]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi

            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;

        create)
            _get_comp_words_by_ref -n : cur prev
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        pull)
            if [[ $cword -eq 2 && "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            fi
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        run)
            if [[ $cword -eq 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            else
                if [[ $cword -gt 2 && "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                fi
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;
        
        show)
            if [[ $cword -eq 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            else
                if [[ $cword -gt 2 && "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                fi
            fi

            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            return

            ;;

        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            
            ;;
        
        *)
            if [[ $cword -eq 1 ]]; then
                COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
            fi
            __ltrim_colon_completions "$cur"
            return

            ;;
    esac
}

complete -F _ollama_completions ollama
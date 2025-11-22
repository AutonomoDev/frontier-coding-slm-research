_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword

    local subcommand=${words[1]}

    case $subcommand in
        show|run|stop|push|cp|rm)
            # Group 1 commands requiring <MODEL> completion
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
                return
            fi

            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models

            if [[ $subcommand == stop ]]; then
                # Special rule for `stop`
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi

            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Group 2 commands with flags
            if [[ $cword -eq 2 ]]; then
                local cur prev
                _get_comp_words_by_ref -n : cur prev

                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }

                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword -gt 2 && $prev == -* ]]; then
                case $cur in
                    --file|-f|--quantize|-q)
                        COMPREPLY=()
                        ;;
                    *)
                        COMPREPLY=( $(compgen -W '--file -f --quantize -q' -- "$cur") )
                        ;;
                esac
            fi
            ;;
        pull)
            # Group 2 commands with flags only
            if [[ $cword -gt 1 && $prev == -* ]]; then
                COMPREPLY=( $(compgen -W '--insecure' -- "$cur") )
            else
                COMPREPLY=()
            fi
            ;;
        run)
            # Group 2 commands with flags and model completion
            if [[ $cword -eq 2 ]]; then
                local cur prev
                _get_comp_words_by_ref -n : cur prev

                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }

                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword -gt 2 && $prev == -* ]]; then
                COMPREPLY=( $(compgen -W '--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose' -- "$cur") )
            fi
            ;;
        show)
            # Group 2 commands with flags and model completion
            if [[ $cword -eq 2 ]]; then
                local cur prev
                _get_comp_words_by_ref -n : cur prev

                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }

                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword -gt 2 && $prev == -* ]]; then
                COMPREPLY=( $(compgen -W '--license --modefile --parameters --system --template --verbose' -- "$cur") )
            fi
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # Group 3 commands with no argument completion
            COMPREPLY=()
            ;;
        *)
            # Top-level completion rule
            COMPREPLY=( $(compgen -W 'show run stop push cp rm create pull serve start signin signout list ls ps help' -- "$cur") )
            ;;
    esac

    return 0
}

complete -F _ollama_completions ollama


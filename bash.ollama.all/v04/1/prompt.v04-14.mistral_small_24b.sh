_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword
    local subcommand="${words[1]}"

    case "$subcommand" in
        show|run|stop|push|cp|rm)
            # Group 1 commands requiring <MODEL> completion

            if [[ $cword == 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                if [[ "$subcommand" == "stop" ]]; then
                    models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                else
                    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                fi
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        create)
            # Group 2 commands with flags

            if [[ $cword == 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword == 3 && "$cur" == -* ]]; then
                local flags="--file -f --quantize -q"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        pull)
            # Group 2 commands with flags only

            if [[ $cword == 2 && "$cur" == -* ]]; then
                local flags="--insecure"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        run)
            # Group 1 commands requiring <MODEL> completion

            if [[ $cword == 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword == 3 && "$cur" == -* ]]; then
                local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        show)
            # Group 1 commands requiring <MODEL> completion

            if [[ $cword == 2 ]]; then
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword == 3 && "$cur" == -* ]]; then
                local flags="--license --modefile --parameters --system --template --verbose"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # Group 3 commands with no argument completion

            COMPREPLY=()
            ;;
        *)
            # Top-level command completion

            local subcommands="show run stop push cp rm create pull serve start signin signout list ls ps help"
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            ;;
    esac
}

complete -F _ollama_completions ollama


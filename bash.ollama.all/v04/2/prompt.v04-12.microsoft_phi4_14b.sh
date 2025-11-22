```bash
_ollama_completions() {
    _get_comp_words_by_ref -n : cur prev words cword

    local subcommand="${words[1]}"

    case "$subcommand" in
        show|run|stop|push|cp|rm)
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Step B — Fetch Models (special for 'stop')
            if [[ "$subcommand" == "stop" ]]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi

            # Step C — Generate
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D — Sort + Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;

        create)
            # Model completion first, then flags
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if [[ ${cword} -eq 2 ]]; then
                # Fetch Models
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cur == -* ]]; then
                # Flags
                local flags="--file -f --quantize -q"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;

        pull)
            if [[ ${cword} -eq 2 && $cur == -* ]]; then
                # Flags only for 'pull'
                local flags="--insecure"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;

        run)
            # Model completion first, then flags
            if [[ ${cword} -eq 2 ]]; then
                # Fetch Models
                # Step A — Extract
                local cur prev
                _get_comp_words_by_ref -n : cur prev

                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cur == -* ]]; then
                # Flags
                local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;

        show)
            if [[ ${cword} -eq 2 ]]; then
                # Model completion first, then flags
                # Step A — Extract
                local cur prev
                _get_comp_words_by_ref -n : cur prev

                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cur == -* ]]; then
                # Flags
                local flags="--license --modefile --parameters --system --template --verbose"
                COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            fi
            ;;

        *)
            if [[ ${cword} -eq 2 ]]; then
                # Top-level completion for subcommands
                local commands="show run stop push cp rm create pull serve start signin signout list ls ps help"
                COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            fi
            ;;
    esac
}

complete -F _ollama_completions ollama
```


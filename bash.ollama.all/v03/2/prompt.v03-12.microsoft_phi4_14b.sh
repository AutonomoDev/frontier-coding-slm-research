# [[HUMAN COMMENTED-OUT]]
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    case "${prev}" in
        ollama)
            COMPREPLY=($(compgen -W "create help list ls models new push pull run serve show start stop" -- "$cur"))
            return
            ;;
        create|pull|run|show)
            if ! command -v ollama &>/dev/null; then 
                COMPREPLY=()
                return
            fi

            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
                return
            fi
            ;;
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
                return
            fi
            ;;
        run|stop)
            if ! command -v ollama &>/dev/null; then 
                COMPREPLY=()
                return
            fi

            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        run)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                return
            fi
            ;;
        show)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                return
            fi
            ;;
        stop)
            local ps_output
            if ! command -v ollama &>/dev/null; then 
                COMPREPLY=()
                return
            fi

            ps_output=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$ps_output" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$ps_output" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        *)
            if [[ ${#words[@]} -eq 1 ]]; then
                local subcommands
                subcommands=$(ollama help | awk '/Commands:/,0' | tail -n +2)
                COMPREPLY=($(compgen -W "$(echo "$subcommands" | tr ' ' '\n' | grep '^  [a-z]' | sed 's/^  //')" -- "$cur"))
            fi
            ;;
    esac
}

complete -F _ollama_completions ollama
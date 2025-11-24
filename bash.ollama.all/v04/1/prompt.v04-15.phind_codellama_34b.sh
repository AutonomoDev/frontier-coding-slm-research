# [[HUMAN COMMENTED-OUT]]
# Here is the required Bash completion function:

_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    case "${words[1]}" in
        show|run|stop|push|cp|rm)
            # Step A
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create|pull)
            case "${words[2]}" in
                -*)
                    local opts="--file -f --quantize -q --insecure"
                    COMPREPLY=($(compgen -W "$opts" -- "$cur"))
                    return 0
                    ;;
            esac

            # Step A
            _get_comp_words_by_ref -n : cur prev

            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        stop)
            # Step A
            _get_comp_words_by_ref -n : cur prev

            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        run|signout)
            return 0
            ;;
        *)
            local subcmds="show run stop push cp rm create pull serve start signin signout list ls ps help"
            COMPREPLY=($(compgen -W "$subcmds" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
    esac
} && complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This function implements the completion rules as described in your task, and registers it using `complete -F`.

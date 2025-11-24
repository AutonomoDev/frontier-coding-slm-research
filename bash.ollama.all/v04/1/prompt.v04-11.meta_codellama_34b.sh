# [[HUMAN COMMENTED-OUT]]
# Here is a fully-working bash completion function for the `ollama` CLI:
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    case "${words[1]}" in
        show | run | stop)
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Step B — Fetch Models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C — Generate
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D — Sort + Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        push)
            # Same as show/run/stop
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        cp)
            # Same as show/run/stop
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        rm)
            # Same as show/run/stop
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Step B — Fetch Models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C — Generate
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D — Sort + Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        pull)
            # Step A — Extract
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            # Step B — Fetch Models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Step C — Generate
            COMPREPLY=($(compgen -W "$models" -- "$cur"))

            # Step D — Sort + Trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        stop)
            # Same as show/run/stop, but with a different models command.
            local cur prev
            _get_comp_words_by_ref -n : cur prev

            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        serve)
            # No completion.
            return 0
            ;;
        start)
            # No completion.
            return 0
            ;;
        signin)
            # No completion.
            return 0
            ;;
        signout)
            # No completion.
            return 0
            ;;
        list)
            # No completion.
            return 0
            ;;
        ls)
            # No completion.
            return 0
            ;;
        ps)
            # No completion.
            return 0
            ;;
        help)
            # No completion.
            return 0
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}
complete -F _ollama_completions ollama
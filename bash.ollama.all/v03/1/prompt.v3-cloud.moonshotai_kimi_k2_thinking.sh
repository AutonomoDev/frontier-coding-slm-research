_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Top-level completion: complete subcommands when previous word is 'ollama'
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "create cp help list ls ps pull push rm run serve show signin signout start stop" -- "$cur"))
        return
    fi

    local subcommand="${COMP_WORDS[1]}"

    # Flag completion (only after model, so position > 2)
    if [[ "$cur" == -* && $COMP_CWORD -gt 2 ]]; then
        case "$subcommand" in
            create)
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
                return
                ;;
            pull)
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
                return
                ;;
            run)
                COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                return
                ;;
            show)
                COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                return
                ;;
        esac
    fi

    # Model completion (at position 2) or no completion
    case "$subcommand" in
        show|run|push|cp|rm)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # Precise implementation Steps A-D for Group 1 commands
                local cur prev
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=()
            fi
            ;;
        stop)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # Precise implementation but using ollama ps
                local cur prev
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=()
            fi
            ;;
        create|pull)
            if [[ $COMP_CWORD -eq 2 ]]; then
                # Model completion for commands with flags
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=()
            fi
            ;;
        serve|start|list|ls|ps|signin|signout|help)
            # No argument completion
            COMPREPLY=()
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
        return
    fi

    local subcmd=${words[1]}

    case $subcmd in
        show|run|push|cp|rm)
            # Steps A-D for model completion
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            if [[ $cword -eq 2 ]]; then
                # Model completion first
                _ollama_completions
                return
            fi
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        pull)
            if [[ $cword -eq 2 ]]; then
                COMPREPLY=()
            else
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # No completion
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama


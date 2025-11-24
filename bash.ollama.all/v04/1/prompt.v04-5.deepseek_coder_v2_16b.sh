_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
        return
    fi

    local models
    case ${words[1]} in
        show)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        run)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            if [[ "$cur" == -* ]]; then
                COMPREPLY+=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi
            ;;
        pull)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            ;;
        cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
    esac
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
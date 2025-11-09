function _ollama_completions {
    local cur prev models
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    case "${prev}" in
        show|run|stop|push|cp|rm)
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create)
            COMPREPLY=()
            local opts="--file -f --quantize -q"
            [[ $cur == -* ]] && COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
        pull)
            COMPREPLY=()
            local opts="--insecure"
            [[ $cur == -* ]] && COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
        run)
            COMPREPLY=()
            local opts="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            [[ $cur == -* ]] && COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
        show)
            COMPREPLY=()
            local opts="--license --modefile --parameters --system --template --verbose"
            [[ $cur == -* ]] && COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
    esac
}

complete -F _ollama_completions ollama

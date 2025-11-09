 ```bash
function _ollama_completions {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ ${cword} == 1 ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start list ls ps help" -- "$cur"))
        return 0
    fi

    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return 0
    fi

    case "${words[1]}" in
        show)
            COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
            ;;
        run)
            COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
            ;;
        stop)
            COMPREPLY=($(compgen -W "$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')" -- "$cur"))
            ;;
        push|cp|rm)
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
        pull)
            COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            ;;
    esac
}

complete -F _ollama_completions ollama
```


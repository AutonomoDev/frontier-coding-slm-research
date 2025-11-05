 ```bash
function _ollama_completions {
    local cur prev models
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then
        COMPREPLY=(); return;
    fi

    case "$prev" in
        show|run|stop|push|cp|rm)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            if [[ -z "$models" ]]; then
                COMPREPLY=(); return;
            fi
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            local flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$flags" -- "$cur"))
            ;;
        serve|pull|signin|signout|list|ps|help)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
```


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
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            COMPREPLY=()
            local flags="--file -f --quantize -q"
            case "$cur" in
                --*)
                    COMPREPLY=($(compgen -W "$flags" -- "$cur"))
                    ;;
                *)
                    ;;
            esac
            ;;
        serve|pull|signin|signout|list|ps|help)
            COMPREPLY=()
            ;;
        *)
            local commands="show run stop push cp rm create serve pull signin signout list ps help"
            COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            ;;
    esac
}

complete -F _ollama_completions ollama
```


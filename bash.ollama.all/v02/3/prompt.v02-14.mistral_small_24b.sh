```bash
_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        ollama)
            COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
            ;;
        show|run|stop|push|cp|rm)
            # Fetch models and generate completions for commands requiring <MODEL> completion
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Special flag completion for the `create` command
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
        serve|pull|signin|signout|list|ps|help)
            # Commands with no argument completion
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
```


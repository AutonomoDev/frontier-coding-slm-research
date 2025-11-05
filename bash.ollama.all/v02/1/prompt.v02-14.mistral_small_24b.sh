```bash
_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        ollama)
            COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
            return 0
            ;;
        show|run|stop|push|cp|rm)
            # Fetch models and provide completion for model names
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Provide completion for flags
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            return 0
            ;;
        serve|pull|signin|signout|list|ps|help)
            # No argument completion needed
            COMPREPLY=()
            return 0
            ;;
    esac
}

complete -F _ollama_completions ollama
```


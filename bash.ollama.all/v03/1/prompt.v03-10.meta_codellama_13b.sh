```bash
_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        ollama) # Top-level completion
            COMPREPLY=($(compgen -W "show run create serve start pull signin signout list ls ps help" -- "$cur"))
            return 0
            ;;
        show|run|create) # Model name completion (Group 1 commands)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        create) # Special flag completion (Group 2 commands)
            case "$cur" in
                -f|--file)
                    COMPREPLY=($(compgen -W "--file --quantize --insecure" -- "$cur"))
                    return 0
                    ;;
                *) # Fallback to default completion
                    _default_completion
                    ;;
            esac
            ;;
        serve|start|pull) # No argument completion (Group 3 commands)
            COMPREPLY=($(compgen -W "serve start pull" -- "$cur"))
            return 0
            ;;
        stop) # Model name completion with ollama ps output (Group 4 command)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        *) # Fallback to default completion
            _default_completion
            ;;
    esac
}
complete -F _ollama_completions ollama
```


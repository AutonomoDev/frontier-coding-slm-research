```
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    local subcmd=${words[1]}
    local models
    case $subcmd in
        show | run | stop)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            if [ "$subcmd" = "stop" ]; then
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        push)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return
            fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        pull)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        rm)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        cp)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}
complete -F _ollama_completions ollama
```


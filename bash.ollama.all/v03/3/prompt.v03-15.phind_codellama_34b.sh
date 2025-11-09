```bash
# Bash completion for 'ollama' command
function _ollama_completions() {
    local cur prev opts
    _get_comp_words_by_ref -n : cur prev

    case $prev in
        create|pull|run|show)
            COMPREPLY=($(compgen -W "--file -f --quantize -q --insecure" -- "$cur"))
            ;;
        stop|rm)
            # Generate model names for 'stop' and 'rm' commands
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        *)
            # Subcommands for 'ollama' command
            opts="create pull run stop rm show serve start signin signout list ls ps help"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
    esac

    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
```



Here's a sample Bash script that should satisfy the above requirements:
```bash
# Define the `_ollama_completions` function
_ollama_completions() {
    # Check if the `ollama` command is available
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Fetch models for certain subcommands
    local models
    case "$prev" in
        show|run|stop|push|cp|rm)
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') ;;
        create)
            models=$(ollama list --all-models 2>/dev/null | tail -n +2 | awk '{print $1}') ;;
    esac

    # Generate completions for the current word
    case "$cur" in
        -*) COMPREPLY=($(compgen -W "-h --help -v --version")) ;;
        *) COMPREPLY=($(compgen -W "$models")) ;;
    esac

    # Sort and trim the completions
    __ltrim_colon_completions "$cur"
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
}
complete -F _ollama_completions ollama
```


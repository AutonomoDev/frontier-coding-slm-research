```bash
# Bash completion for 'ollama' command
_ollama_completions() {
    local cur prev words cword subcommand modelcmds
    _init_completion || return

    # Set up the model fetching function
    get_models() {
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    }

    # Set up the main completion function
    _main() {
        case $prev in
            create)
                modelcmds='--file -f --quantize -q'
                COMPREPLY=($(compgen -W "$modelcmds" -- "$cur"))
                ;;
            *)
                get_models
                ;;
        esac
    }

    # Call the main completion function
    _main

    # Sort and trim completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
```


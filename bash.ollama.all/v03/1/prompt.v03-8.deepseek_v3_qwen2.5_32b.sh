_complete_ollama_commands() {
    # Return all possible subcommands for ollama when first argument is provided
    local commands=(
        'create' 'pull' 'run' 'stop' 'push' 'cp' 'rm'
        'show' 'serve' 'start' 'signin' 'signout'
        'list' 'ls' 'ps' 'help'
    )
    COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
}

_complete_model_names() {
    # Fetch and complete models from `ollama list`
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && {
        COMPREPLY=()
        return
    }

    # Generate completions, sort them, and trim colons
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

_complete_stop_commands() {
    # Fetch models from `ollama ps` and complete them
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local running_models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$running_models" ]] && {
        COMPREPLY=()
        return
    }

    COMPREPLY=($(compgen -W "$running_models" -- "$cur"))
}

_complete_flags() {
    local command=$1
    local flags

    case "$command" in
        create)
            flags="--file -f --quantize -q"
            ;;
        pull)
            flags="--insecure"
            ;;
        run)
            flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            ;;
        show)
            flags="--license --modefile --parameters --system --template --verbose"
            ;;
    esac

    COMPREPLY=($(compgen -W "$flags" -- "--"))
}

_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Handle top-level completion (no subcommand yet)
    if [[ $cword -eq 1 ]]; then
        _complete_ollama_commands
        return
    fi

    case "$prev" in
        create|pull|run|show)
            _complete_flags "$prev"
            ;;
        stop)
            _complete_stop_commands
            ;;
        *)
            if [[ $cur == -* ]]; then
                # Handle flags after model for commands like run, show, etc.
                return 1 # No completions for flags in this scenario (only for specific cases above)
            else
                case "$prev" in
                    ollama|create|pull|run|stop|push|cp|rm|show) _complete_model_names ;;
                esac
            fi
    esac
}

# Register completion function
complete -F _ollama_completions ollama

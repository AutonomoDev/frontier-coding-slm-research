_ollama_completions() {
    local cur prev words cword subcommand model_commands model_flags
    _get_comp_words_by_ref -n : cur prev words cword

    # Top-level completion: list all commands if the previous word is 'ollama'
    case "$prev" in
        ollama)
            COMPREPLY=( $(compgen -W "create serve start pull show stop run create push cp rm ls list ps signin signout help" -- "$cur") )
            return 0
            ;;
    esac

    # Extract subcommand (the command after 'ollama')
    for ((i=1; i < ${#words[@]}; i++)); do
        if [[ "${words[i]}" =~ ^- ]]; then continue; fi
        subcommand=${words[i]}
        break
    done

    case "$subcommand" in
        # Commands that require model completion (Group 1)
        create|show|run|stop|push|cp|rm)
            local models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        # Commands with special flag completions (Group 2)
        create)
            model_flags="--file -f --quantize -q"
            COMPREPLY=($(compgen -W "$model_flags" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        pull)
            model_flags="--insecure"
            COMPREPLY=($(compgen -W "$model_flags" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        run)
            model_flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
            COMPREPLY=($(compgen -W "$model_flags" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        show)
            model_flags="--license --modefile --parameters --system --template --verbose"
            COMPREPLY=($(compgen -W "$model_flags" -- "$cur"))
            __ltrim_colon_completions "$cur"
            ;;
        stop)
            # For 'stop', fetch running models from 'ollama ps'
            local running_models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            running_models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$running_models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=( $(compgen -W "$running_models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        # Commands that take no arguments (Group 3)
        serve|start|pull|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return
            ;;
    esac

    return 0
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

_ollama_completions() {
    local cur prev words cword subcommand models
    _get_comp_words_by_ref -n : cur prev words cword

    # Extract subcommand (words[1])
    if [[ $cword -lt 2 ]]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
        return
    fi
    subcommand=${words[1]}

    case $subcommand in
        # Group 3: Empty completion commands
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
        # Group 2A: 'create' with model and flags
        create)
            local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=( $(compgen -W "$models --file -f --quantize -q" -- "$cur") )
            ;;
        # Group 2B: 'pull' with flags only
        pull)
            COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
            ;;
        # Group 1 and other commands
        show|run|stop|push|cp|rm)
            local models_str=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            if [[ $subcommand == stop ]]; then
                models_str=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            fi
            [[ -z "$models_str" ]] && { COMPREPLY=(); return; }
            # Generate and sort completions
            local completions=( $(compgen -W "$models_str" -- "$cur") )
            if [[ ${#completions[@]} -gt 0 ]]; then
                COMPREPLY=( $(printf "%s\n" "${completions[@]}" | sort) )
                __ltrim_colon_completions "$cur"
            else
                # If no models, check for flags (only applies to 'run')
                if [[ $subcommand == run ]]; then
                    COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") )
                fi
            fi
            ;;
        # Group 2C: 'run' with flags (after model)
        run)
            if [[ $prev == ollama ]]; then
                _ollama_completions create  # Reuse 'create's logic for models
                return
            else
                local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=( $(compgen -W "$flags" -- "$cur") )
            fi
            ;;
        # Group 2D: 'show' with flags (after model)
        show)
            local flags="--license --modefile --parameters --system --template --verbose"
            if [[ $prev == ollama ]]; then
                _ollama_completions create  # Reuse 'create's logic for models
                return
            else
                COMPREPLY=( $(compgen -W "$flags" -- "$cur") )
            fi
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama


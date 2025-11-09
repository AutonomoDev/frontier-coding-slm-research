_ollama_completions() {
    local cur prev words cword
    _init_completion || return

    # Get the subcommand (first argument after 'ollama')
    local subcommand=""
    if [[ ${#words[@]} -gt 1 ]]; then
        subcommand="${words[1]}"
    fi

    # If completing right after 'ollama', show all subcommands
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "serve start create show run stop pull push cp rm list ls ps signin signout help" -- "$cur"))
        return
    fi

    # Handle subcommand-specific completions
    case "$subcommand" in
        show|push|cp|rm)
            # These commands need a model name
            if [[ $cword -eq 2 ]]; then
                # Step A: Extract word info
                _get_comp_words_by_ref -n : cur prev
                # Step B: Fetch models
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                # Step C: Generate completions
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                # Step D: Sort and trim
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        run)
            if [[ $cword -eq 2 ]]; then
                # Model name completion for run
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword -gt 2 ]]; then
                # Flag completion after model
                COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
            fi
            ;;
        stop)
            if [[ $cword -eq 2 ]]; then
                # Get running models from ps command
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            ;;
        create)
            if [[ $cword -eq 2 ]]; then
                # Model name - no completion, user provides new name
                COMPREPLY=()
            elif [[ $cword -gt 2 ]]; then
                # Flag completion after model name
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            fi
            ;;
        pull)
            if [[ $cword -eq 2 ]]; then
                # Model name - no completion, user provides remote model
                COMPREPLY=()
            elif [[ $cword -gt 2 ]]; then
                # Flag completion after model name
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            fi
            ;;
        show)
            if [[ $cword -eq 2 ]]; then
                # Model name completion for show
                _get_comp_words_by_ref -n : cur prev
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            elif [[ $cword -gt 2 ]]; then
                # Flag completion after model
                COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
            fi
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # No argument completion for these commands
            COMPREPLY=()
            ;;
    esac
}

# Register the completion function
complete -F _ollama_completions ollama

```bash
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        # Top-level completion for all subcommands when the word before is `ollama`
        ollama)
            COMPREPLY=($(compgen -W "create run show stop push cp rm pull serve start list ls ps help signout signin" -- "$cur"))
            return
            ;;
        
        # Commands that require <MODEL> completion
        show|run|stop|push|cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        
        # Command with special flag completion
        create)
            case "$cur" in
                -*)
                    COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
                    return
                    ;;
            esac
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                # Model name completion after the flags
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            else
                # Model name completion after the flags
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        
        run)
            case "$cur" in
                -*)
                    COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
                    return
                    ;;
            esac
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                # Model name completion after the flags
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        
        show)
            case "$cur" in
                -*)
                    COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
                    return
                    ;;
            esac
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                # Model name completion after the flags
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        
        # Commands with no argument completion
        serve|start|list|ls|ps|help|signin|signout)
            COMPREPLY=()
            ;;
        
        # Handle `stop` command by listing models using `ollama ps`
        stop)
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                local model_list
                model_list=$(ollama ps 2>/dev/null | awk '{print $1}')
                [[ -z "$model_list" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$model_list" -- "$cur"))
            fi
            ;;
        
        # Default case to handle unexpected scenarios
        *)
            COMPREPLY=()
            ;;
    esac
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama
```


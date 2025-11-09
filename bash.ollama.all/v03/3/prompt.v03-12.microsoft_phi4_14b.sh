_ollama_completions() {
    local cur prev words cword split=false
    _get_comp_words_by_ref -n : cur prev

    case "$prev" in
        # Top-level completion for 'ollama'
        ollama)
            COMPREPLY=( $(compgen -W "create show run stop push cp rm pull serve start list ls ps help signin signout signout" -- "$cur") )
            return
            ;;
        
        # Commands requiring <MODEL> completion
        show|run|stop|push|cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Generate completions based on model names
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
        
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
                return
            fi
            ;;
        
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
                return
            fi
            
            # Fetch models for `ollama ps`
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Generate completions based on model names from ollama ps
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
        
        run)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") )
                return
            fi
            
            # Fetch models for `ollama list`
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Generate completions based on model names from ollama list
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
        
        show)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
                return
            fi
            
            # Fetch models for `ollama list`
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }

            # Generate completions based on model names from ollama list
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            __ltrim_colon_completions "$cur"
            ;;
        
        # Commands with no argument completion
        serve|start|list|ls|ps|help|signin|signout)
            return
            ;;
        
    esac
}

complete -F _ollama_completions ollama

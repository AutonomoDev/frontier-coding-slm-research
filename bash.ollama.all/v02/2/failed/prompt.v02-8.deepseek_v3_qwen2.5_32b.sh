# Bash Completion Script for 'ollama' Command

_ollama_completions() {
    local cur prev cmd
    COMPREPLY=()
    
    # Extract the current and previous words
    _get_comp_words_by_ref -n : cur prev cmd
    
    case "$prev" in
        ollama)
            # Top-level completions: list all subcommands
            COMPREPLY=( $(compgen -W "create push pull serve rm cp stop show run signin signout list ps help" -- "$cur") )
            ;;
        
        create)
            # Completion for 'create' command flags
            COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
            ;;
    esac
    
    case "$cmd" in
        show|run|stop|push|cp|rm)
            # Fetch model names using ollama list and process them
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return 0
            fi
            
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            
            if [ -z "$models" ]; then
                COMPREPLY=()
                return 0
            fi
            
            # Generate completions from model names
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            
            # Sort and trim colon completions
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
    esac
    
    return 0
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

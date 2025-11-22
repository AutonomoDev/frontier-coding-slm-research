# Main Function: _ollama_completions
_ollama_completions() {
    local cur prev subcommand
    # Extract Word Info (Step A)
    _get_comp_words_by_ref -n : cur prev

    # Top-Level Completion
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W "create show run stop push cp rm serve start pull signin signout list ls ps help" -- "$cur"))
        return 0
    fi

    # Subcommand Completion Logic
    subcommand=${COMP_WORDS[1]}
    case $subcommand in
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
        pull)
            COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            ;;
        run)
            if [ $COMP_CWORD -eq 2 ]; then
                # Model Name Completion Logic (Steps B-D)
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
            else
                # Flags Completion for run subcommand
                COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
            fi
            ;;
        show)
            if [ $COMP_CWORD -eq 2 ]; then
                # Model Name Completion Logic (Steps B-D)
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
            else
                # Flags Completion for show subcommand
                COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
            fi
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        *)  # Commands with no argument completion (Group 3)
            COMPREPLY=()
    esac
}

# Register the completion function at the end
complete -F _ollama_completions ollama

# Main Function
_ollama_completions() {
    local cur prev
    
    # Step A: Extract Word Info
    _get_comp_words_by_ref -n : cur prev

    # Top-Level Completion
    if [ "${COMP_CWORD}" -eq 1 ]; then
        COMPREPLY=( $( compgen -W 'show run stop push cp rm create serve pull signin signout list ps help' -- "$cur" ) )
    else
        case "${prev}" in
            show | run | stop | push | cp | rm)  # Commands requiring <MODEL> completion
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models  # Must be a string, not an array
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
                # Step C: Generate Completions
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                
                # Step D: Sort and Trim
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            ;;
            create)  # Command with special flag completion
                COMPREPLY=( $( compgen -W '--file -f --quantize -q' -- "$cur" ) )
            ;;
            serve | pull | signin | signout | list | ps | help)  # Commands with no argument completion
                return
            ;;
        esac
    fi
}

# Register the function
complete -F _ollama_completions ollama
# [[HUMAN COMMENTED-OUT]]
# This script generates a Bash completion for `ollama` command, which has the above described behaviour and constraints.

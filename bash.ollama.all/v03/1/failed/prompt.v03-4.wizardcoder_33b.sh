# Main Function
_ollama_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Top-Level Completion
    if [ "${COMP_CWORD}" -eq 1 ]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- $cur))
        
    # Completion for 'create' command.
    elif [ "${prev}" = "create" ]; then
        COMPREPLY=($(compgen -W "-f --file -q --quantize" -- $cur))
    
    # Completion for 'pull' command.
    elif [ "${prev}" = "pull" ]; then
        COMPREPLY=($(compgen -W "--insecure" -- $cur))
        
    # Completion for 'run' command.
    elif [ "${prev}" = "run" ]; then
        COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- $cur))
        
    # Completion for 'show' command.
    elif [ "${prev}" = "show" ]; then
        COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- $cur))
    
    # Model Name Completion
    elif [ "${COMP_WORDS[1]}" = "run" ] || \
         [ "${COMP_WORDS[1]}" = "show" ] || \
         [ "${COMP_WORDS[1]}" = "stop" ] || \
         [ "${COMP_WORDS[1]}" = "push" ] || \
         [ "${COMP_WORDS[1]}" = "cp" ] || \
         [ "${COMP_WORDS[1]}" = "rm" ]; then
    
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        
        # Generate Completions, sort and trim.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function.
complete -F _ollama_completions ollama

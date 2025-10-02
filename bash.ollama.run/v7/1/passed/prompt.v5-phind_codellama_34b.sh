_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if we are completing the first argument to 'run'
    if [ "$prev" = "run" ]; then
        # Get a list of all available local models
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}') || return

        # Temporarily remove colon from COMP_WORDBREAKS
        local old_wb=$COMP_WORDBREAKS
        COMP_WORDBREAKS=${old_wb//:}

        # Generate a list of matching model names
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Restore the original value of COMP_WORDBREAKS
        COMP_WORDBREAKS=$old_wb

        # Disable file completion if no matches found
        if [ ${#COMPREPLY[@]} -eq 0 ]; then
            compopt -o default
        fi
    fi
} &&
complete -F _ollama_run_completion ollama


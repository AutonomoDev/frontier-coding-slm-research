_ollama_completions() {
    local cur prev words cword models

    # Check if the first argument is 'run' to narrow down completion scope.
    [[ "${COMP_WORDS[1]}" != "run" ]] && return 0

    # Save the original COMP_WORDBREAKS for restoration later
    local original_comp_wordbreaks="${COMP_WORBDREAKS}"
    
    # Temporarily remove colon from word breaks to prevent splitting model names like 'codellama:13b'
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Reparse the command line to get accurate cur and prev, handling colons properly
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks immediately after re-parsing
    COMP_WORDBREAKS="${original_comp_wordbreaks}"

    # Only complete model names if 'run' is the previous command
    if [[ "$prev" == "run" ]]; then
        # Retrieve model names from ollama list, skipping header line and columns beyond first (name)
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions based on cur, using compgen to match against retrieved models
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

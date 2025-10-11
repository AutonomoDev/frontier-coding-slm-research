_ollama_completions() {
    local cur prev models

    # Check if the first argument is "run"; proceed only then.
    [[ ${COMP_WORDS[1]} == "run" ]] || return 0

    # Save original COMP_WORDBREAKS and remove colon from it to allow colons in completions
    local saved_wordbreaks="${COMP_WORDBREAKS}"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Reparse the command line with _get_comp_words_by_ref to handle colons correctly
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks immediately after parsing
    COMP_WORDBREAKS="${saved_wordbreaks}"

    # If previous word is "run", complete model names from 'ollama list' command
    if [[ ${prev} == "run" ]]; then
        # Extract model names (first column) from the output of ollama list, skipping header line
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions using compgen, matching current word with available models
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

# Completion function for 'ollama' command
_ollama_completions() {
    local words cur prev models

    # Check if first argument is 'run'
    [[ ${COMP_WORDS[1]} == "run" ]] || return 0

    # Save original COMP_WORDBREAKS and remove colon from it to handle colons in model names
    local orig_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with _get_comp_words_by_ref, treating colon as part of words
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS to prevent side effects on other completions
    COMP_WORDBREAKS=$orig_wb

    # If the previous word is 'run', complete model names from ollama list output
    if [[ $prev == "run" ]]; then
        models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama


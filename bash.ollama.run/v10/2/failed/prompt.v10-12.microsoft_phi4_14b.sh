# Function to handle completions for 'ollama run'
_ollama_completions() {
    # Check if the first argument is "run"
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Save original COMP_WORDBREAKS and modify it to handle colons correctly
    local orig_comp_wbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with colon support for current and previous words
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately after parsing
    COMP_WORDBREAKS=$orig_comp_wbreaks

    # If the word before "run" is empty, we are looking to complete model names
    if [[ $prev == "" ]]; then
        # Retrieve list of models using 'ollama list' and extract the first column from the second line onward
        local models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Generate completion matches based on current word input and available model names
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi

    return 0
}

# Register the completion function for the 'ollama run' command
complete -F _ollama_completions ollama

#!/bin/bash

# Function to handle completions for the `ollama` command
_ollama_completions() {
    # Check if the first argument is "run"
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Save the original COMP_WORDBREAKS to a local variable
    local old_comp_wordbreaks=$COMP_WORDBREAKS

    # Remove the colon from COMP_WORDBREAKS by using parameter expansion
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the current and previous words, ensuring colons are not treated as breaks
    _get_comp_words_by_ref -n : cur prev

    # Immediately restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS=$old_comp_wordbreaks

    # If `prev` is "run", generate completions
    if [[ "$prev" == "run" ]]; then
        # Retrieve model names using `ollama list | awk 'NR>1 {print $1}'` or an equivalent command that extracts only the first column starting from the second line
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Use `compgen -W "$models" -- "$cur"` to generate the reply array `COMPREPLY`
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register completion
complete -F _ollama_completions ollama


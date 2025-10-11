# Ollama Completion Script for Bash-Completion Framework

# Function to handle completions for the 'ollama' command
_ollama_completions() {
    local cur prev models

    # Check if the first argument is "run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Save original COMP_WORDBREAKS and remove colon for proper parsing
    local original_breaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the current and previous words, handling colons correctly
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS to avoid breaking other completions
    COMP_WORDBREAKS=$original_breaks

    # Check if previous word is "run", then generate model name completions
    if [ "$prev" = "run" ]; then
        # Retrieve model names from 'ollama list' command output
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate the reply array with matching model names using compgen
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama

# Function to handle completions for the `ollama` command
_ollama_completions() {
    # Check if the first argument is "run"
    local first_arg="${COMP_WORDS[1]}"
    if [[ "$first_arg" != "run" ]]; then
        return 0
    fi

    # Save original COMP_WORDBREAKS and remove colon from it to handle colons in model names
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

    # Re-parse the command line with _get_comp_words_by_ref, ensuring colons are not treated as breaks
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately after re-parsing
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # If the previous word is "run", generate completions for model names
    if [[ "$prev" == "run" ]]; then
        # Retrieve model names using `ollama list` and extract only the first column starting from the second line
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions for the current word based on retrieved model names
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi

    return 0
}

# Register the completion function with the `ollama` command
complete -F _ollama_completions ollama

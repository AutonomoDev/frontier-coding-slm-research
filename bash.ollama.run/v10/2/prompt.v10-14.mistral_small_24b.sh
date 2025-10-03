# Define the function to handle completions for the `ollama` command
_ollama_completions() {
    # Check if the first argument is "run". If not, return early.
    local first_arg="${COMP_WORDS[1]}"
    if [[ "$first_arg" != "run" ]]; then
        return 0
    fi

    # Save the original COMP_WORDBREAKS to a local variable
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"

    # Remove the colon from COMP_WORDBREAKS by using parameter expansion.
    # This is necessary because colons in model names should not be treated as word breaks.
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

    # Re-parse the current and previous words, ensuring colons are not treated as breaks
    _get_comp_words_by_ref -n : cur prev

    # Immediately restore the original COMP_WORDBREAKS to avoid side effects
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # If `prev` is "run", generate completions for model names
    if [[ "$prev" == "run" ]]; then
        # Retrieve model names using `ollama list | awk 'NR>1 {print $1}'`
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Use compgen to generate the reply array COMPREPLY with the retrieved model names
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi

    return 0
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

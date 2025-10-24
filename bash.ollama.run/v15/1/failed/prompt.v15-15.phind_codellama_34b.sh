# [[HUMAN COMMENTED-OUT]]
# Here is an example of a Bash completion script for `ollama run`:

# This function will provide completions for the "ollama run" command.
_ollama_run_completions() {
    # Save original word breaks and set new ones, so colons don't split words.
    ORIG_COMP_WORDBREAKS="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${ORIG_COMP_WORDBREAKS//:/}
    
    # Re-parse current and previous words, to get correct behavior with colons.
    _get_comp_words_by_ref -n : cur prev

    # Restore original word breaks.
    COMP_WORDBREAKS="$ORIG_COMP_WORDBREAKS"

    # Check that the second word on the command line is "run".
    if [[ "$prev" != "run" ]]; then
        return 0
    fi
    
    # Generate model names from "ollama list".
    local models
    models=$(ollama list --format '{{.Name}}' | awk -F: '{print $1}')
    
    # Generate completions using the model names.
    COMPREPLY=($(compgen -W "$models" -- cur))
}

# Register this function for completion with "ollama run".
complete -F _ollama_run_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script provides the necessary logic to handle `ollama run` commands, dynamically fetches model names from `ollama list`, and correctly handles model names containing colons.

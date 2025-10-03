# Function to handle completions for the `ollama` command
_ollama_completions() {
    local cur prev words cword split
    # Get the current word and previous word using bash-completion framework utilities
    _get_comp_words_by_ref -n :cur:prev:

    # Check if the first argument is "run"
    if [[ "${prev}" != "run" ]]; then
        return
    fi

    # Save and temporarily remove colon from COMP_WORDBREAKS to avoid word splitting issues
    local original_comp_wordbreaks=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get the list of models using `ollama list` and parse only the first column (model names)
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Restore COMP_WORDBREAKS to its original state
    COMP_WORDBREAKS=${original_comp_wordbreaks}

    # Generate completions based on the available models
    COMPREPLY=($(compgen -W "${models}" -- ${cur}))
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

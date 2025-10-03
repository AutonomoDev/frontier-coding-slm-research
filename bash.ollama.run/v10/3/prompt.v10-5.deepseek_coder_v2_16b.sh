# Generate completions for `ollama run` command
function _ollama_completions {
    local cur prev words cword split
    # Get the current and previous words using bash-completion framework functions
    _get_comp_words_by_ref -n : cur prev

    # Check if the first argument is "run"
    if [[ "${words[1]}" != "run" ]]; then
        return 1
    fi

    # Save and modify COMP_WORDBREAKS to handle colons properly in completions
    local original_comp_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Get the list of models using `ollama list` and extract model names
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS=$original_comp_wordbreaks

    # Generate completions using `compgen` with the extracted model names
    COMPREPLY=($(compgen -W "$models" -- $cur))
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

# Function to handle completions for the `ollama` command.
_ollama_completions() {
    # Only proceed if the first subcommand is "run".
    local cur prev words cword split
    _get_comp_words_by_ref -n : cur prev

    # Check if the previous word is "run"; only complete model names in this case.
    if [[ ${prev} != "run" ]]; then
        return
    fi

    # Save current COMP_WORDBREAKS and modify it to not split on colons for correct parsing.
    local original_comp_worbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with modified word breaks.
    _get_comp_words_by_ref -n : cur prev

    # Restore COMP_WORDBREAKS to its original value immediately after parsing.
    COMP_WORDBREAKS="$original_comp_worbreaks"

    # Retrieve available model names from `ollama list`.
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate possible completions for the current word using compgen.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function with bash-completion framework.
complete -F _ollama_completions ollama

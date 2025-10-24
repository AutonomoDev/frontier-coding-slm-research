# ollama run completion script

_ollama_run_completions() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur: -n :prev: -n :words: -n :cword: -n :split

    # Check if the previous word is "run" and handle completion accordingly
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 1
    fi

    # Save the original COMP_WORDBREAKS
    local orig_comp_wordbreaks=$COMP_WORDBREAKS

    # Remove colon from COMP_WORDBREAKS to allow completion across colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Get the list of models using ollama list
    local models=$(ollama list | tail -n +2 | awk '{print $1}')

    # Restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS=$orig_comp_wordbreaks

    # Generate completion suggestions based on available models
    compgen -W "$models" -- "$cur"
}

# Register the completion function for the ollama run command
complete -F _ollama_run_completions ollama
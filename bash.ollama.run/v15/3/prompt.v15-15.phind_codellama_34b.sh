#!/bin/bash
# This completion script assumes 'ollama' is installed and in the user's PATH

_ollama_run_completions() {
    # Save the original COMP_WORDBREAKS
    local saved_comp_wordbreaks="$COMP_WORDBREAKS"

    # Remove colon from COMP_WORDBREAKS
    COMP_WORDBREAKS=${saved_comp_wordbreaks//:}

    # Re-parse the current and previous words, excluding colons
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS="$saved_comp_wordbreaks"

    # Check if the second word is "run"
    if [[ "$prev" != "run" ]]; then
        return 0
    fi

    # Generate a list of models and parse out the model names from the first column
    local IFS=$'\n'
    local models=( $(ollama list --quiet | tail -n +2 | cut -d ' ' -f 1) )

    # Generate completions based on the current word
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
}
complete -F _ollama_run_completions ollama
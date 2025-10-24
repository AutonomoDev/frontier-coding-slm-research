#!/bin/bash

# Function to provide completions for `ollama run`
_ollama_run_completions() {
    # Save original COMP_WORDBREAKS and modify it to handle colons in model names
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Check if the second word is "run"
    [[ "${COMP_WORDS[1]}" == "run" ]] || return 0

    # Fetch model names from `ollama list`
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Provide completions for the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completions ollama
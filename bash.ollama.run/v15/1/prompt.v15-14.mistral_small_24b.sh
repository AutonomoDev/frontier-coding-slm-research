#!/bin/bash

_ollama_run_completions() {
    # Save original COMP_WORDBREAKS and remove colon from it
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"

    # Re-parse the current and previous words with the modified COMP_WORDBREAKS
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Check if the second word is "run"
    [[ "${COMP_WORDS[1]}" == "run" ]] || return 0

    # Fetch model names from ollama list command
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Provide the list of suggestions to COMPREPLY
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

# Register the completion function for ollama run command
complete -F _ollama_run_completions ollama
#!/bin/bash

# Function to generate completions for ollama command
_ollama_completions() {
    # Check if first argument is "run"
    local cur prev words cword
    _get_comp_words_by_ref -n = cur prev words cword
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Handle colon in word breaks
    local original_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev words cword
    COMP_WORDBREAKS=$original_wordbreaks

    # Completion logic for "run" subcommand
    if [[ "${prev}" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
    fi
}

# Register completion function for ollama command
complete -F _ollama_completions ollama

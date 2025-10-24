#!/bin/bash

_ollama_run_completions() {
    # Temporarily modify COMP_WORDBREAKS for colon handling
    local cur prev cword words
    _get_comp_words_by_ref -n =: cur prev words cword
    
    if [[ ${COMP_WORDS[1]} == "run" ]]; then
        # Get the list of model names
        local models=$(ollama list | tail -n +2 | awk '{print $1}')
        
        # Generate completions using compgen
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
    
    return 0
}

complete -F _ollama_run_completions ollama

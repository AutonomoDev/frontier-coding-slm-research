#! /usr/bin/env bash

_ollama_run_completion() {
    local cur prev words cword split
    _init_completion -s || return

    # Temporarily remove colon from COMP_WORDBREAKS to handle model names correctly
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    if [[ $cword -eq 2 ]]; then
        # Get the list of models from ollama list command
        local model_list=$(ollama list | awk 'NR>1 {print $1}')
        
        # Restore COMP_WORDBREAKS to its original state before filtering completions
        COMP_WORDBREAKS=$old_wb

        # Generate completion suggestions based on the current word being typed
        COMPREPLY=($(compgen -W "$model_list" -- $cur))
    else
        # Restore COMP_WORDBREAKS to its original state before returning
        COMP_WORDBREAKS=$old_wb
    fi
}

complete -F _ollama_run_completion ollama

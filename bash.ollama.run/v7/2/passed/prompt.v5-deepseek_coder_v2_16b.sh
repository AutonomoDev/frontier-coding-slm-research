#!/bin/bash

_ollama_run_completion() {
    local cur prev words cword split
    _init_completion -s || return

    if [[ $cword -ne 2 ]]; then
        return
    fi

    # Get the list of models
    local model_list=$(ollama list | awk 'NR>1 {print $1}')

    # Handle colons in word breaks temporarily
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    COMPREPLY=()
    if [[ -n "$cur" ]]; then
        local suggestions=$(echo "$model_list" | grep "^$cur")
        COMPREPLY=( $(compgen -W "$suggestions" -- $cur) )
    else
        COMPREPLY=( $(compgen -W "$model_list" -- $cur) )
    fi

    # Restore the original word breaks
    COMP_WORDBREAKS=$old_wb
}

complete -F _ollama_run_completion ollama

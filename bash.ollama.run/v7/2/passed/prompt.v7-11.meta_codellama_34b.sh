#!/bin/bash

_ollama_run_completion() {
    # Define variables
    local cur prev words cword run_index
    _get_comp_words_by_ref -n : cur prev words cword

    # Hack to make sure COMP_WORDS and COMP_CWORD are correct
    for (( i = 0; i < ${#words[@]}; i++ )); do
        if [[ ${words[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion if the current word is immediately after 'run'
    if [ $cword -ne $((run_index + 1)) ]; then
        return
    fi

    # Temporarily remove colon from COMP_WORDBREAKS so we can parse model names containing colons
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get a list of available models by parsing the output of 'ollama list'
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Restore COMP_WORDBREAKS to its original value
    COMP_WORDBREAKS=$old_wb

    # Generate completion suggestions
    compopt -o nospace 2>/dev/null
    local IFS=$'\n'
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Make sure there are no duplicate suggestions
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY=()
    fi
}

complete -F _ollama_run_completion ollama


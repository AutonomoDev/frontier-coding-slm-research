#!/bin/bash

_ollama_run () {
    local cur prev models

    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev

    if [[ "$prev" == "run" ]]; then
        # Get the list of available local models
        models=$(ollama list | awk '{print $1}' | sort -u)

        # Filter the suggestions based on the word being completed
        COMPREPLY+=($(compgen -W "$models" -- "$cur"))
    fi
}

complete -F _ollama_run ollama

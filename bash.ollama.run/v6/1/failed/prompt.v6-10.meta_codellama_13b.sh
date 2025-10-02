#!/bin/bash

_ollama_completion() {
    local cur prev models

    COMPREPLY=()
    _get_comp_words_by_ref cur prev

    # Only run the completion if the first word is "ollama" and the previous word is "run"
    if [[ ${cur} == ollama && ${prev} == run ]]; then
        models=$(ollama list | cut -d ' ' -f 1)
        COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
    fi
}

complete -F _ollama_completion ollama

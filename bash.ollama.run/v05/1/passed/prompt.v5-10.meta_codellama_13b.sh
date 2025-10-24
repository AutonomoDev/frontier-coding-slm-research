#!/bin/bash

_ollama_run() {
    local cur prev models

    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev

    if [[ "$cur" == *:* ]] || [[ ${COMP_WORDS[0]} != ollama ]]; then
        return 1
    fi

    models=$(ollama list | awk '{print $1}' | sort -u)

    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}
complete -F _ollama_run ollama run

#!/bin/bash

_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only activate when the command is `ollama run`
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    COMPREPLY=( $( compgen -W "$( ollama list | awk 'NR>1{print $1}' )" -- ${cur} ) )
    __ltrim_colon_completions "${COMPREPLY[@]}"
}

complete -F _ollama -o default ollama

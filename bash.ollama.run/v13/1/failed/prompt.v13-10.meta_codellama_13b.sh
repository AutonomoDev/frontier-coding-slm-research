#!/bin/bash

_ollama_run () {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Use _get_comp_words_by_ref -n : to prevent colon splitting
    opts=$(ollama list | awk '{print $1}')
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )

    __ltrim_colon_completions "$cur"

    return 0
}

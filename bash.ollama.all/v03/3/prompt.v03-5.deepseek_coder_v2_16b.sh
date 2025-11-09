#!/bin/bash

function _ollama_completions {
    local cur prev opts models
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    printf "%s\n" "${COMPREPLY[@]}" | sort
}

complete -F _ollama_completions ollama
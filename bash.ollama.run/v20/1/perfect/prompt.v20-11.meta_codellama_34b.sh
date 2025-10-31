#!/bin/bash

_ollama_completions() {
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return  # (1) Validate command

    local cur prev  # (3) Extract word info
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then  # (4) Fetch models
        COMPREPLY=()
        return
    fi

    local models  # (5) Generate completions
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))  # (6) Sort + trim
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama  # (7) Register completion function

#! /usr/bin/env bash

_ollama_completions() {
    local cur prev words cword split
    if ! _get_comp_words_by_ref -n : cur prev; then
        compopt -o nospace
        COMPREPLY=()
        return 0
    fi

    if [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    local models=$(ollama list | awk 'NR>1 {print $1}')
    local IFS=$'\n'
    local matches=($(compgen -W "$models" -- "${cur}"))
    COMPREPLY=("${matches[@]}")
    
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        COMPREPLY=()
    fi

    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

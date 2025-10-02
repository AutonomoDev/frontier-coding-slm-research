#!/bin/bash

_ollama_completions() {
    # Check if ollama command exists
    type -P ollama &>/dev/null || return 1

    # Get current word and previous word for parsing
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Check if previous word is "run"
    if [[ "${prev}" != "run" ]]; then return 1; fi

    # Get model names using ollama list and parse with awk/while loop to extract first column, skipping header row
    models=$(ollama list | awk 'NR>1{print $1}' FS=' ')

    # Filter matches using array iteration and pattern matching against cur
    COMPREPLY=()
    for model in ${models}; do
        if [[ "${model}" =~ ^${cur} ]]; then
            COMPREPLY+=("${model}")
        fi
    done

    # Sort matches and use compgen -W to generate COMPREPLY
    sorted_matches="${COMPREPLY[*]}"
    COMPREPLY=()
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "${cur}") )

    # Call __ltrim_colon_completions to properly handle colon-separated completions display
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama

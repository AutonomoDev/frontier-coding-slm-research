#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || return 1

    # Check if the first word is 'ollama' and the previous word is 'run'
    if [[ ${words[0]} != "ollama" ]] || [[ ${prev} != "run" ]]; then
        return 1
    fi

    # Get the list of available models by running `ollama list`
    local model_list
    model_list=$(ollama list)

    # Extract model names from the output, skipping the header line
    local model_names
    model_names=$(echo "$model_list" | tail -n +2 | cut -d ' ' -f 1)

    # Filter model names based on the current word being typed
    COMPREPLY=($(compgen -W "${model_names}" -- ${cur}))

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# Fallback to manually set cur and prev if _get_comp_words_by_ref is missing or fails
_get_comp_words_by_ref() {
    local exclude=()
    local words cword cur prev
    if [[ $COMP_CWORD == 0 ]]; then
        cur=""
        prev=""
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    eval "$1=${words[@]}"
    eval "$2=$cword"
}

# Source this script to enable the completion functionality
if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
    source "$0"
fi
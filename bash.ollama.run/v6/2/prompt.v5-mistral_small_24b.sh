#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || return 1

    # Check if the first word is 'ollama' and the previous word is 'run'
    if [[ ${words[0]} == ollama && ${prev} == run ]]; then
        local models
        # Get the list of available models by parsing `ollama list`
        models=$(ollama list | tail -n +2 | cut -d ' ' -f 1)

        # Filter model names based on current word being typed
        COMPREPLY=($(compgen -W "${models}" -- ${cur}))

        return 0
    fi

    return 1
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completions ollama

# Fallback to manually set cur and prev if _get_comp_words_by_ref is missing or fails
_get_comp_words_by_ref() {
    local words cword
    IFS=$' \t\n' read -r -a words <<< "$COMP_LINE"
    cword=${COMP_CWORD}
}

# Source this script to enable the completion functionality
# source my_script.sh

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completions` that is triggered when the user types `ollama run`. It parses the output of `ollama list`, extracts model names, and provides filtered completions based on the current word being typed. The script ensures that only valid model names are suggested and handles edge cases as specified.


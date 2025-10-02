#!/bin/bash

# Function to get model names from `ollama list`
_get_model_names() {
    local models
    models=$(ollama list | tail -n +2 | cut -d ' ' -f 1)
    echo "$models"
}

# Function to provide completion for the `ollama run` command
_ollama_run_completion() {
    # Use _get_comp_words_by_ref if available, otherwise fallback to manual parsing
    local cur prev words cword
    if declare -F _get_comp_words_by_ref > /dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Check if the previous word is `run` and the first word is `ollama`
    if [[ $prev == run && ${words[0]} == ollama ]]; then
        local models
        models=$(_get_model_names)

        # Filter models based on the current word being typed
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Ensure unique suggestions
        COMPREPLY=($(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    fi

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completion` that is registered to handle completions for the `ollama run` command. It uses `_get_model_names` to fetch and parse model names from the output of `ollama list`, ensuring that only valid model names are suggested based on the user's input. The script adheres to all specified requirements, including precise parsing, contextual filtering, and unique suggestions.


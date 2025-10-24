#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completions() {
    local cur prev words cword

    # Fallback if _get_comp_words_by_ref is not available or fails
    if [[ -z ${COMP_WORDS[1]} ]]; then
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    else
        _get_comp_words_by_ref cur prev words cword
    fi

    # Check if the second word is `run`
    if [[ "${words[1]}" != "run" ]]; then
        return 0
    fi

    # Get the current word being completed
    local current_word="${cur}"

    # Extract model names from `ollama list` output
    local models
    models=$(ollama list | tail -n +2 | cut -d ' ' -f 1)

    # Filter models based on the current word
    COMPREPLY=($(compgen -W "${models}" -- ${current_word}))

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completions ollama


#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completion() {
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword; then
        :
    else
        # Fallback in case `_get_comp_words_by_ref` is not available or fails
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Check if the second word is `run`
    if [[ ${words[1]} == "run" ]]; then
        # Extract model names from `ollama list` output
        local models
        models=$(ollama list | tail -n +2 | cut -d ' ' -f 1)

        # Filter models based on the current word being typed
        COMPREPLY=($(compgen -W "$models" -- $cur))

        # Remove duplicates from COMPREPLY
        COMPREPLY=($(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    fi

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completion` that is triggered when completing the `ollama run` command. It parses the output of `ollama list`, extracts model names, and provides filtered completions based on the user's input. The script ensures compliance with all specified requirements and avoids common pitfalls.


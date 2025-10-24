#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completions() {
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword; then
        :
    else
        # Fallback: manually set cur and prev from COMP_WORDS/COMP_CWORD
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the second word is 'run'
    if [[ "${words[1]}" == "run" ]]; then
        local models
        # Get the list of available models and parse it
        models=$(ollama list | tail -n +2 | cut -d' ' -f1)

        # Filter models based on the current word being typed
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        return 0
    fi

    # If not completing `run`, do nothing
    return 1
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completions ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completions` that is registered to handle completions for the `ollama run` command. It ensures that only model names are suggested and filters them based on the current input, adhering strictly to the requirements specified.


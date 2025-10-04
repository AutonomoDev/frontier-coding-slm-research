#!/bin/bash

# Function to provide bash completion for `ollama run <model>`
_ollama_run_completion() {
    local cur prev opts models

    # Get the current word and previous word from the command line
    COMP_WORDS=("${COMP_WORDS[@]}")
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the previous word is 'ollama' and the current word is empty, list available models
    if [[ "$prev" == "run" ]]; then
        # Capture the output of `ollama list` and extract model names
        models=$(ollama list 2>/dev/null | awk '{print $1}' | tr -d ':')
        COMPREPLY=($(compgen -W "${models}" -- ${cur}))
    fi

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# Installation snippet to add to .bashrc or .bash_profile
# echo 'source /path/to/this/script' >> ~/.bashrc && source ~/.bashrc

# [[HUMAN COMMENTED-OUT]]
# This script defines a bash completion function `_ollama_run_completion` that dynamically lists available models by parsing the output of `ollama list`. It uses standard Bash features and avoids any external dependencies. The installation snippet shows how to add this script to your `.bashrc` or `.bash_profile` for automatic loading.
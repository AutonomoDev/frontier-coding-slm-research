#!/bin/bash

# This script provides bash completion for the `ollama run` command.

# Source the bash-completion library.
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Function to get the list of available models.
_ollama_run_models() {
    local models
    models=$(ollama list | tail -n +2 | cut -d' ' -f1)
    echo "$models"
}

# Completion function for ollama run.
_ollama_run_completion() {
    local cur prev words
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")

    # Check if the command is ollama run.
    if [[ "${words[0]}" == "ollama" && "${prev}" == "run" ]]; then
        local models
        models=$(_ollama_run_models)

        # Filter the models based on the current word.
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )

        # Remove duplicate suggestions
        COMPREPLY=($(sort -u "$COMPREPLY"))
    fi
}

# Register the completion function.
complete -F _ollama_run_completion ollama run

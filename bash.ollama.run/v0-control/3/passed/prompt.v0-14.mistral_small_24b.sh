#!/bin/bash

_ollama_run() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Check if the command is `ollama run`
    if [[ ${COMP_WORDS[1]} == "run" ]]; then
        # Get available models from `ollama list` output
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | tr '\n' ' ')
        if [[ -z "$models" ]]; then
            return 0
        fi

        # Complete the model names
        COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
    else
        # If not `ollama run`, fallback to default completion
        COMPREPLY=()
    fi

    return 0
}

complete -F _ollama_run ollama

# Installation snippet for the user's .bashrc or .bash_profile
echo '
# Ollama run command completion
if [ -f /path/to/this/script ]; then
    source /path/to/this/script
fi
' >> ~/.bashrc

# [[HUMAN COMMENTED-OUT]]
# This script defines a bash-completion function `_ollama_run` that dynamically lists available models by parsing the output of `ollama list`. It handles errors gracefully and adheres to Bash completion conventions. The installation snippet shows how to add this completion function to the user's `.bashrc` or `.bash_profile`.
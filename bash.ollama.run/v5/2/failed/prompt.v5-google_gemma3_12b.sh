#!/bin/bash

# ############################################################################
# ollama run completion script for bash-completion
#
# This script provides autocompletion suggestions for model names when a user
# types `ollama run ` and presses the `<TAB>` key.
# ############################################################################

# ############################################################################
# Function to get the list of available models
# ############################################################################
_ollama_run_completion() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local models
    local prefix

    # Get the list of available models from ollama list
    models=$(ollama list | tail -n +2 | cut -d' ' -f1)

    # If the user is completing the word immediately after 'run'
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        prefix="${cur%%[*]}"  # Get the prefix of the word being completed

        # Filter the models based on the prefix
        COMPREPLY=($(echo "$models" | grep "^$prefix" | sort))

        # Remove duplicates
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort -u))

        # If no matches are found, provide no suggestions
        if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
            return 0
        fi
    fi
}

# ############################################################################
# Register the completion function
# ############################################################################
if ! type -t _ollama_run_completion >/dev/null; then
  complete -F _ollama_run_completion ollama run
fi


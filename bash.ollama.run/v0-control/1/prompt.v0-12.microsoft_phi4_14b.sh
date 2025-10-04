#!/bin/bash

# Define the completion function for 'ollama run'
_ollama_run_completion() {
    # Declare local variables to hold temporary data
    local cur prev opts models

    # Read current word (word before cursor), previous word, and options from COMP_WORDS and COMP_CWORD
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the current subcommand is 'run' or empty (for initial completion of first argument)
    if [[ $prev == run || -z $prev ]]; then
        # Run `ollama list` and capture its output
        models=$(ollama list 2>/dev/null)

        # Check if `models` has content, otherwise return empty options
        if [[ -n "$models" ]]; then
            # Extract the model names from the output using awk to skip headers
            opts=$(echo "$models" | awk 'NR>1 {print $1}')

            # Set COMPREPLY array with extracted models for completion
            COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
        fi

        # Return success code
        return 0
    fi

    # If not completing after 'run', do nothing and let the default completions apply
    return 1
}

# Install the completion function using the built-in bash-completion feature
if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
    complete -F _ollama_run_completion ollama
else
    # Fallback for Bash < 4.0 (Optional, depends on shell specifics)
    echo "Bash version is too old to support dynamic completions."
fi

# Comment: The above script sets up a bash completion function for `ollama run`.
# It captures available models using the output of `ollama list` by skipping headers.
# This ensures that only model names are considered for autocompletion. 
# The completion is installed conditionally, with error handling for older Bash versions.

# [[HUMAN COMMENTED-OUT]]
# This script provides a self-contained and portable solution to dynamically complete the `ollama run <model>` command using native bash tools without any external dependencies. It handles errors gracefully by suppressing output errors from `ollama list` and providing fallback messages when necessary.

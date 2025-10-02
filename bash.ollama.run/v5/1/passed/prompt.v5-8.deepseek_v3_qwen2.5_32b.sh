#!/bin/bash

# Define a Bash completion function for the 'ollama run' command.
#
# The function will provide autocompletion suggestions based on local models listed by `ollama list`.
# It ensures that only model names are considered and skips the header line of the output.

_ollama_run_complete() {
    # Extract the current word being completed (COMP_WORDS[COMP_CWORD])
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Ensure we're completing the second argument after 'run'
    if [ "${#COMP_WORDS[@]}" -ne 3 ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Get list of model names from `ollama list` command, skipping header line and extracting first column.
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Filter the models to match the current word's prefix.
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    return 0
}

# Register the completion function for ollama run subcommand.
complete -F _ollama_run_complete ollama

# Explanation of script:
# The script defines a completion function '_ollama_run_complete' that triggers when 'ollama run' is partially typed.
# It fetches model names by invoking 'ollama list', parses the output, and filters them based on what's being typed.


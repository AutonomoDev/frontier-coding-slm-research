#!/usr/bin/env bash
#
# Bash completion for `ollama run <model>`
# --------------------------------------------------
# This script registers a completion function that
# dynamically lists available Ollama models by parsing
# the output of `ollama list`.  It requires only Bash
# and the default POSIX utilities that ship with
# most Linux/macOS distributions.
#
# Installation:
#   1. Save this file to a location such as:
#        ~/.bash_completion.d/ollama_run
#   2. Ensure it is executable:
#        chmod 644 ~/.bash_completion.d/ollama_run
#   3. Source it from your shell init file (e.g. ~/.bashrc):
#        [[ -r ~/.bash_completion.d/ollama_run ]] && source ~/.bash_completion.d/ollama_run
#
# After that, pressing TAB after `ollama run` will show
# the currently available models.
#

# ----------------------------------------------
# Completion function
# ----------------------------------------------
_ollama_run_complete() {
    local cur prev models

    # Initialize completion reply array
    COMPREPLY=()

    # Current word to complete and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only complete after the subcommand "run"
    if [[ "$prev" != "run" ]]; then
        return 0
    fi

    # Grab model names from `ollama list`.
    # We ignore the header line and take the first field of each data line.
    # Failure of `ollama` should not abort the completion.
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models were found, give up gracefully
    if [[ -z "$models" ]]; then
        return 0
    fi

    # Use `compgen` to generate the list of matches
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    return 0
}

# Register the completion for the `ollama` command
complete -F _ollama_run_complete ollama

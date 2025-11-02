#!/usr/bin/env bash
#
# Bash completion for the command "ollama run <model>"
# This function dynamically lists available models by parsing the output of "ollama list".
# It filters completions based on the current word and handles errors silently.
#

_ollama_run() {
    # Get the current word being completed.
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Only complete if the user has typed "ollama run"
    if [[ ${#COMP_WORDS[@]} -ge 2 && "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Capture output from "ollama list", ignoring any errors.
    local out
    if ! out=$(command ollama list 2>/dev/null); then
        return 0
    fi

    # Parse each line (or whitespace separated token) into an array.
    local models=()
    while read -r model; do
        [ -z "$model" ] || models+=("$model")
    done <<< "$out"

    # Generate completion suggestions matching the current word prefix.
    COMPREPLY=( $(compgen -W "$(printf '%s ' "${models[@]}")" -- "$cur") )
}

complete -F _ollama_run ollama run

# Installation/Activation Instructions:
#
# 1. Save this script as "ollama-completion.bash".
# 2. Source it in your shell configuration file (e.g., ~/.bashrc or ~/.profile):
#
#      . /path/to/ollama-completion.bash
#
# 3. Reload your shell configuration (or restart your terminal) for the changes to take effect.
#    Alternatively, you can immediately source the script:
#
#      source /path/to/ollama-completion.bash

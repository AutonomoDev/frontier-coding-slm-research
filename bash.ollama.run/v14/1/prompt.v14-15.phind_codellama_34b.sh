#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# This is a Bash completion script for `ollama run <model>`. Please note that it should be used in a shell environment and may require some adjustments based on the specifics of your system/implementation.

_ollama_completions() {
    # Array index check (CORRECT)
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse models from ollama list output
    local models=()
    IFS=$'\n'
    for line in $(ollama list 2>/dev/null); do
        if [[ "$line" == NAME* ]]; then
            continue
        fi
        model=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model" ]]; then
            models+=("$model")
        fi
    done

    # Generate completions
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Fix colon display (MANDATORY)
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script meets all the requirements listed. It verifies that the command is `ollama run` before attempting completion, properly handles colon-separated model names, and parses the `ollama list` output correctly. It also checks if the `ollama` command exists before attempting to complete models.

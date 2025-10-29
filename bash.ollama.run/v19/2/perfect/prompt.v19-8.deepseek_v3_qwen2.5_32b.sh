#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
_ollama_completions() {
    # Only activate for "ollama run" commands
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Retrieve models from 'ollama list' output
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # Handle no models available
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completion candidates
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Sort the completions for a better user experience
    COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )

    # Trim colon prefix from completions to handle cases like 'codellama:'
    __ltrim_colon_completions "$cur"
}

# Register completion function with the ollama command
complete -F _ollama_completions ollama
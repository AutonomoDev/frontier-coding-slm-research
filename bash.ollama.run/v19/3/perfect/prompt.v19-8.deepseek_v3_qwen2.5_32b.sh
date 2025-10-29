#!/bin/bash

# Analyzing for malicious intent...
# - No superuser permissions requested
# - No file writing operations
# - Only reads from 'ollama list' command
# - Standard bash completion functionality
# Code appears safe.

_ollama_completions() {
    # Only activate for 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev

    # Set cur to the current word, handling colons
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama is installed
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch available models from 'ollama list'
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models are found, provide empty completion
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate possible completions based on the current word (cur)
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Sort the completions to maintain order (e.g., alphabetical)
    COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )

    # Trim colon from completion options if current word ends with colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
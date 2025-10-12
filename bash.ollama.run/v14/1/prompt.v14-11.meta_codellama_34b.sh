#!/bin/bash

# Function declaration
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons
    _get_comp_words_by_ref -n : cur prev
    if [ $? -ne 0 ]; then
        COMPREPLY=()
        return
    fi

    # Parse models
    models=$(ollama list 2>/dev/null)
    if [ $? -ne 0 ]; then
        COMPREPLY=()
        return
    fi
    IFS=$'\n' read -d '' -r -a models <<<"$models"

    # Generate completions
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Fix colon display
    __ltrim_colon_completions "$cur"  # NEVER SKIP THIS!
}

# Register
complete -F _ollama_completions ollama

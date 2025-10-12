#!/bin/bash

# Function Declaration: Create _ollama_completions()
function _ollama_completions() {
    local cur prev opts

    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get current and previous word for completion
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Handle colons in model names
    _get_comp_words_by_ref -n : cur

    # Parse models from `ollama list` output
    opts=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate completions
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))

    # Fix colon display (MANDATORY)
    __ltrim_colon_completions "$cur"
}

# Register: complete -F _ollama_completions ollama
complete -F _ollama_completions ollama
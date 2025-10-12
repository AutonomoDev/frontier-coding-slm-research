#!/bin/bash
# Bash completion script for `ollama run <model>`

_ollama_completions() {
    local cur prev cword models

    # Check if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    # Handle colons in model names
    _get_comp_words_by_ref -n : cur prev || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Parse models using ollama list, skipping the header and extracting only the model name
    if command -v ollama &>/dev/null; then
        mapfile -t models < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    else
        return
    fi

    # Generate completions and set COMPREPLY
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Fix colon display in model names
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
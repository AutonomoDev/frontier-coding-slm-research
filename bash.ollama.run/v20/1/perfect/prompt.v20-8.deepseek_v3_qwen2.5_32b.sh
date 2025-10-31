#!/bin/bash

_ollama_completions() {
    # Check if the command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama is installed and fetch models
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions based on current input and available models
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Sort the completions for better readability
    COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )

    # Trim colon prefixes if any (codellama:<TAB>)
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
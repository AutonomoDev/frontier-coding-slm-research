#!/bin/bash

_ollama_completions() {
    # Get completion variables with colon handling
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if the command is "ollama run" (using COMP_WORDS is fine for these)
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Use process substitution to avoid subshell for the while loop
    local models=()
    while IFS= read -r line; do
        # Skip header and empty lines
        if [[ "$line" =~ ^NAME.*ID.*SIZE.*MODIFIED || -z "$line" ]]; then
            continue
        fi

        # Extract model name (first column)
        model_name=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model_name" ]]; then
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null)

    # If no models found, return
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Complete using the models array as a single space-separated string
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Fix for colons - this needs the colon-aware $cur
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
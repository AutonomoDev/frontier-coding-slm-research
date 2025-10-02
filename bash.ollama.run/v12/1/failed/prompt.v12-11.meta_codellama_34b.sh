#!/bin/bash

_ollama_completions() {
    # Check if the first word is "ollama" and the previous word is "run"
    if [[ $1 != ollama || $2 != run ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colons in model names
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Completion logic for "ollama run"
    if [[ $prev == run ]]; then
        # Check if the "ollama" command exists
        if ! command -v ollama &> /dev/null; then
            COMPREPLY=()
            return 0
        fi

        # Get model names from "ollama list"
        local models=($(ollama list 2>/dev/null | awk 'NR > 1 && $1 != "" {print $1}'))

        # Return if no models found
        if [[ ${#models[@]} -eq 0 ]]; then
            COMPREPLY=()
            return 0
        fi

        # Get matches for the current word
        local matches=()
        for model in "${models[@]}"; do
            if [[ $model == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        # Sort matches and set COMPREPLY
        sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
        COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    fi

    # Fix suggestions after colons
    __ltrim_colon_completions "$cur"
}

# Register completion function
complete -F _ollama_completions ollama

#!/bin/bash

# Define completion function for ollama run command
_ollama_completions() {
    local cur prev models matches sorted_matches

    # Handle colon splitting in Bash completion
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    # Only complete model names after 'ollama run'
    if [[ "$1" != "ollama" ]] || [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi
    # Check if ollama command exists and get the list of models
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip header and empty lines, extract model name (first column)
        if [[ ! "$line" =~ ^NAME.*ID.*SIZE.*MODIFIED$ && -n "$line" ]]; then
            model=$(echo "$line" | awk '{print $1}')
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)
    # If no models, set COMPREPLY=() and return
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi
    # Generate matches (model names starting with "$cur")
    for model in "${models[@]}"; do
        if [[ "${model}" == "${cur}"* ]]; then
            matches+=("$model")
        fi
    done
    # Sort the matches and set COMPREPLY
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    # Fix colon handling in Bash completion (suggestions show correctly after colons)
    __ltrim_colon_completions "$cur"
}
# Register the completion function for ollama command
complete -F _ollama_completions ollama


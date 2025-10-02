#!/bin/bash

_ollama_completions() {
    # Handle colons (IMPORTANT)
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Subcommand check
    if [ "$cur" != "ollama" ] || [ "$prev" != "run" ]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get models from "ollama list" output
    local models=( )
    while read line; do
        if [[ "$line" =~ ^NAME ]]; then
            continue
        elif [ -z "$line" ]; then
            continue
        else
            models+=( $(echo "$line" | awk '{print $1}') )
        fi
    done < <(ollama list 2>/dev/null)

    # If no models, return early
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Get matches with compgen
    local sorted_matches=( )
    for model in "${models[@]}"; do
        if [[ "$model" =~ ^"$cur" ]]; then
            sorted_matches+=( $(compgen -W "$sorted_matches" -- "$model") )
        fi
    done

    # Set COMPREPLY with matches and colon fix
    COMPREPLY=($(printf '%s\n' "${sorted_matches[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register completion function
complete -F _ollama_completions ollama

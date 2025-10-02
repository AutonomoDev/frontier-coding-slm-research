#!/bin/bash

_ollama_completions() {
    # Check if first word is "ollama" and previous word is "run"
    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        COMPREPLY=()
        return
    fi

    # Get current word and previous word, handling colons correctly
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get model names from `ollama list` output
    models=()
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [ "$line" == "NAME ID SIZE MODIFIED" ]; then
            continue
        fi
        name=$(awk '{print $1}' <<< "$line")
        if [ -z "$name" ]; then
            continue
        fi
        models+=("$name")
    done < <(ollama list 2>/dev/null)

    # Check if there are any model names to complete
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Make a list of matches, starting with "$cur"
    matches=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches and set COMPREPLY
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Fix suggestions displaying after colons
    __ltrim_colon_completions "$cur"
}

# Register the completion script
complete -F _ollama_completions ollama

#!/bin/bash

_ollama_completions() {
    # Check if ollama command exists
    command -v ollama > /dev/null || return 0

    # Get current and previous words using _get_comp_words_by_ref or fallback
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if previous word is "run" and current word starts with "-" (options)
    if [[ "${prev}" == "run" && ${cur} == -* ]]; then
        # Get model names using ollama list command
        local models="$(ollama list | awk 'NR>1 {print $1}' | while read -r line; do echo "$line"; done)"

        # Filter matches and sort them
        local sorted_matches=()
        for match in ${models}; do
            if [[ "${match}" == *"${cur}"* ]]; then
                sorted_matches+=("$match")
            fi
        done
        sorted_matches=$(printf '%s\n' "${sorted_matches[@]}" | sort)

        # Generate COMPREPLY using compgen -W and __ltrim_colon_completions
        COMPREPLY=()
        if [ ${#sorted_matches[@]} -gt 0 ]; then
            COMPREPLY=( $(compgen -W "$sorted_matches" -- "${cur}") )
            __ltrim_colon_completions "${cur}"
        fi
    else
        COMPREPLY=()
    fi
}

complete -F _ollama_completions ollama


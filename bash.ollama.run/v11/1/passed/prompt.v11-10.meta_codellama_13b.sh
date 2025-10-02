#!/usr/bin/env bash

_ollama_completions() {
    # Check if ollama command exists
    type -P ollama &> /dev/null || return 1

    # Check subcommand
    [[ ${COMP_WORDS[0]} == "ollama" ]] && [[ ${COMP_WORDS[1]} == "run" ]] || return 2

    # Use _get_comp_words_by_ref to handle colons properly
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Generate completions if previous word is "run"
    [[ ${prev} == "run" ]] && {
        # Retrieve model names using ollama list and parse with awk/while loop to extract first column, skipping header
        models=$(ollama list | awk 'NR>1{print $1}' | while IFS= read -r line; do echo "$line"; done) || return 3

        # Filter matches using array iteration and pattern matching against $cur
        for model in ${models}; do
            [[ "${model}" == "${cur}"* ]] && filtered_matches+=("${model}")
        done

        # Sort matches and use compgen -W to generate COMPREPLY
        sorted_matches=$(printf '%s\n' "${filtered_matches[@]}" | sort) || return 4
        COMPREPLY=($(compgen -W "$sorted_matches" -- "${cur}"))
    }

    # Call __ltrim_colon_completions to properly handle colon-separated completions display
    [[ $COMPV == *:* ]] && __ltrim_colon_completions "$cur" || :
}

# Register completion function
complete -F _ollama_completions ollama

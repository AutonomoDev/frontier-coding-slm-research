#!/bin/bash

# Define completion function for "ollama" command
_ollama_completions() {
    # Check if the current command is "ollama" and previous word is "run"
    if [[ "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[2]}" != "run" ]]; then
        return 0
    fi

    # Handle colon in word breaks for systems with bash-completion
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback to standard COMP_WORDS parsing
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Generate completions if previous word is "run"
    if [[ "${prev}" == "run" ]]; then
        # Retrieve model names using "ollama list" command and parse with awk/while loop
        ollama_list="$(ollama list)"
        while read -r line; do
            # Skip header row and extract first column
            if [[ "${line}" == NAME* ]]; then
                continue
            fi
            model="${line%% *}"
            matches+=("${model}")
        done <<< "${ollama_list}"

        # Filter matches using array iteration and pattern matching against "$cur"
        for ((i=0; i<${#matches[@]}; i++)); do
            if [[ "${matches[i]}" == *"${cur}"* ]]; then
                filtered+=("${matches[i]}")
            fi
        done

        # Sort matches and use "compgen -W" to generate COMPREPLY
        sorted_matches=$(printf '%s\n' "${filtered[@]}" | sort)
        compreply=($(compgen -W "${sorted_matches}" -- ${cur}))

        # CRITICAL COLON HANDLING: Call __ltrim_colon_completions with "$cur" to properly handle colon-separated completions display
        __ltrim_colon_completions "${cur}"
    fi
}

# Register completion function for "ollama" command
complete -F _ollama_completions ollama

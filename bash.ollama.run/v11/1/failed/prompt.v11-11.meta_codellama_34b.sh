#!/bin/bash

# Function to handle completions for the "ollama" command
_ollama_completions() {
    # Check if the command is "ollama" and previous word is "run"
    local cur prev

    # Get the current and previous words separated by a colon
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback to standard COMP_WORDS parsing
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # If the previous word is "run", generate completions
    if [[ "${prev}" == "run" ]]; then
        # Retrieve model names using "ollama list" and parse with awk/while loop to extract first column, skipping header
        local models=$(ollama list | awk 'NR > 1 {print $1}')

        # Filter matches using array iteration and pattern matching against "$cur"
        local filtered_models=()
        for model in ${models[@]}; do
            if [[ "${model}" == *"${cur}"* ]]; then
                filtered_models+=("$model")
            fi
        done

        # Sort matches and use "compgen -W" to generate COMPREPLY
        local sorted_matches=$(echo ${filtered_models[@]} | tr ' ' '\n' | sort)
        compgen -W "${sorted_matches}" -- "$cur"

        # CRITICAL COLON HANDLING: After setting COMPREPLY, call __ltrim_colon_completions to properly handle colon-separated completions display
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion for "ollama" command using "_ollama_completions" function
complete -F _ollama_completions ollama

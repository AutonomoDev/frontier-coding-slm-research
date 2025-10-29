#!/bin/bash

# Analysis: This code provides bash completion for the 'ollama' command. 
# It does not request superuser permissions, does not write to files,
# only reads from ollama command output. No dangerous code detected.

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons (e.g., codellama:)
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command is available
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi

    # Parse models using scalar string approach
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models are available, return an empty completion array
    if [ -z "$models" ]; then 
        COMPREPLY=()
        return
    fi

    # Generate completions based on the current word and available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the generated completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colon-prefixed suggestions to match user input correctly
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
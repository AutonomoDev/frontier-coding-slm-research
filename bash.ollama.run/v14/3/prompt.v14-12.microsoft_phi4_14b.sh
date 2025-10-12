#!/bin/bash

_ollama_completions() {
    # Check if we are completing the 'ollama run' command
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    local cur prev opts
    _get_comp_words_by_ref -n : cur prev  # Handle colons in model names

    # Check if the 'ollama' command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch the list of models from `ollama list`
    local models=$(ollama list 2>/dev/null)
    
    # Skip header and parse model names (first column only) using awk
    mapfile -t model_array < <(echo "$models" | sed '1d' | awk '{print $1}')
    
    # Generate completion options that start with the current prefix
    opts=("${model_array[@]/*$cur/}")  # Use substring filtering to match

    # Sort the resulting completions for better user experience
    COMPREPLY=( $(compgen -W "${opts[*]}" -- "$cur") )

    # Fix colon handling to ensure proper display of completions with colons
    __ltrim_colon_completions "$cur"
}

# Register the completion function with the 'ollama' command
complete -F _ollama_completions ollama
#!/bin/bash
# Bash completion for 'ollama run <model>'
# This function provides completions only when invoking "ollama run"

_ollama_completions() {
    # Check that we are completing the command "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Retrieve current word (cur) and previous token (prev) with colon handling.
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Fallback: use COMP_WORDS[COMP_CWORD] directly if helper is unavailable.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev=""
    fi

    # Ensure the 'ollama' command exists before attempting completions.
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models=()  # Array to hold valid model names from "ollama list"
    
    # Execute "ollama list" and process its output line-by-line.
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines.
        [[ -z "$line" ]] && continue

        # Extract the first column (model name) using awk.
        model_name=$(echo "$line" | awk '{print $1}')
        if [ -n "$model_name" ]; then
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null)

    # Generate completions that match the current prefix.
    COMPREPLY=( $(compgen -W "$(printf '%s ' "${models[@]}")" "$cur" ) )

    # Fix colon splitting issues: always call __ltrim_colon_completions with the current word.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completions ollama
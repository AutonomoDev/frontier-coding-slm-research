#!/bin/bash

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fallback if _get_comp_words_by_ref fails
    if [[ -z "$cur" ]]; then
        cur="${COMP_WORDS[2]}"
    fi

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models
    # Run ollama list and parse the output
    while IFS= read -r line; do
        [[ "$line" == "NAME"* ]] && continue  # Skip header line
        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Filter and sort model names matching the current prefix
    local filtered_models
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            filtered_models+=("$model")
        fi
    done

    COMPREPLY=( $(compgen -W "${filtered_models[@]}" -- "$cur") )

    # Fix colon display
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
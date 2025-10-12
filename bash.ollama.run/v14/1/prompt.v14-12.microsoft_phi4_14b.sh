#!/bin/bash

_ollama_completions() {
    # Check if the current command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get the word currently being completed
    local cur prev opts
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch the list of models from `ollama list` and parse it properly
    local models=()
    IFS=$'\n'
    for line in $(ollama list 2>/dev/null); do
        if [[ "$line" == NAME* ]]; then
            continue  # Skip header line
        fi
        model=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model" ]]; then
            models+=("$model")
        fi
    done

    # Filter the models based on current prefix and sort them
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    # Fix issues with colon handling in Bash completion
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama
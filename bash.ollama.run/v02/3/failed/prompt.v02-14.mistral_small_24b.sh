#!/bin/bash

_ollama_run_completions() {
    local cur prev words cword
    _init_completion || return

    # Check if we are completing after 'ollama run'
    if [[ ${COMP_WORDS[1]} == "run" ]]; then
        # Capture the output of `ollama list` into a variable
        local models
        models=$(ollama list 2>/dev/null)

        # If `ollama list` fails, return with no completions
        if [[ -z "$models" ]]; then
            return
        fi

        # Split the output by whitespace and newlines to handle both cases
        IFS=$'\n' read -r -d '' -a model_array <<<"$models"
        unset IFS

        # Filter models based on the current word being completed
        local filtered_models=()
        for model in "${model_array[@]}"; do
            if [[ $model == "$cur"* ]]; then
                filtered_models+=("$model")
            fi
        done

        # Sort the filtered models alphabetically
        IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
        unset IFS

        # Populate COMPREPLY with the sorted and filtered model names
        COMPREPLY=( "${sorted_models[@]}" )
    fi
}

complete -F _ollama_run_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Installation/activation instructions:
# Save this script to a file, e.g., ~/.bash_completion_ollama.sh.
# Add the following line to your .bashrc or equivalent shell configuration file:
# source ~/.bash_completion_ollama.sh
# Then reload your shell configuration with:
# source ~/.bashrc
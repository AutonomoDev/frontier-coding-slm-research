#!/bin/bash
# This script provides Bash autocompletion for the "ollama run" command.
# It suggests model names based on the output of the "ollama list" command.
#
# Usage:
#   source /path/to/this_script.sh

_ollama_run_completion() {
    # Use _get_comp_words_by_ref if available, with fallback to manual extraction.
    local cur prev_word
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref CUR cur PREV_WORD prev_word
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev_word=${COMP_WORDS[$(( COMP_CWORD - 1 ))]}
    fi

    # Ensure we have at least three words: "ollama run <model>"
    if [[ ${#COMP_WORDS[@]} -lt 3 ]]; then
        return
    fi

    local first_word="${COMP_WORDS[0]}"
    local second_word="${COMP_WORDS[1]}"

    # Only proceed if the command is "ollama run"
    if [[ "$first_word" != "ollama" || "$second_word" != "run" ]]; then
        return
    fi

    # Parse the output of 'ollama list' to extract model names.
    local models=()
    while IFS= read -r line; do
        # Skip header lines that start with NAME
        if [[ "$line" == NAME* ]]; then
            continue
        fi

        # Extract the first field (the model name) using cut.
        local model
        model=$(echo "$line" | cut -d' ' -f1)

        # Only add models that begin with the current user input.
        if [[ "$model" == "$cur"* ]]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # Remove duplicate entries and build a unique list of model names.
    local unique_models
    unique_models=$(printf "%s\n" "${models[@]}" | sort -u)
    
    # Generate the COMPREPLY array using compgen to filter suggestions based on current input.
    COMPREPLY=( $(compgen -W "$unique_models" -- "$cur") )
}

# Register the autocompletion function for the "ollama" command.
complete -F _ollama_run_completion ollama

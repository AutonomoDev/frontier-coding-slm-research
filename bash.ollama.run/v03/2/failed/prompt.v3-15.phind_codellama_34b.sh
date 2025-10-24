#!/bin/bash
# Bash completion for 'ollama'

_ollama() {
    local cur prev opts models
    _get_comp_words_by_ref -n : cur prev

    # Check if we are completing the model argument after `run`
    if [[ $prev != "run" ]] || [[ $cur == *[![:alnum:]_-]* ]]; then
        return 0
    fi

    # Run 'ollama list' and store output in variable
    opts=$(ollama list 2>/dev/null)

    # Check if 'ollama list' failed or returned empty
    if [[ -z $opts ]]; then
        return 0
    fi

    # Iterate over each model and add to array if it starts with the prefix
    while read -r model; do
        if [[ $model == "$cur"* ]]; then
            models+="$model "
        fi
    done <<< "$opts"

    # Sort and assign to COMPREPLY
    IFS=$'\n'
    sort -u <<< "$models" | while read -r model; do
        COMPREPLY+=("$model")
    done
}
complete -F _ollama ollama

# Installation: Save this script as 'ollama-completion.bash' and source it from '.bashrc':
#
#   . ollama-completion.bash
#   source ~/.bashrc


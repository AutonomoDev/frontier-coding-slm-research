#! /usr/bin/env bash

# Ensure this script is sourced and not executed directly
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # Check if the second word (after 'ollama run') exists and is exactly 'run'
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Get the list of models from ollama list command
        COMPREPLY=()
        local model_list=$(ollama list | awk 'NR>1 {print $1}')
        
        # Extract the word being completed (the last word)
        local cur="${COMP_WORDS[COMP_CWORD]}"
        
        # Generate possible completions based on the current word
        COMPREPLY=( $(compgen -W "$model_list" -- $cur) )
    fi
fi



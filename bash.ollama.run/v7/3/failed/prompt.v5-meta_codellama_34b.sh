#!/bin/bash

_ollama_run_completion() {
    # Use a subshell to avoid polluting the caller's environment
    (
        # Enable extended globbing for prefix matching
        shopt -s extglob

        # Get the current word and previous word
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Remove the colon from the list of word separators
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Run `ollama list` and parse the output to get a list of model names
        ollama_list=$(ollama list)
        model_names=()
        while IFS='' read -r line; do
            name="${line%%:*}"
            if [[ "$name" == *:* ]]; then
                # Skip models with colons (they are not supported by `ollama run`)
                continue
            fi
            model_names+=("$name")
        done <<<"$ollama_list"

        # Restore the colon to COMP_WORDBREAKS
        COMP_WORDBREAKS=${COMP_WORDBREAKS:+:}

        # If the previous word is not `run`, do nothing
        if [[ "$prev" != "run" ]]; then
            return 0
        fi

        # Filter the list of model names based on the current word
        COMPREPLY=()
        while IFS='' read -r name; do
            if [[ "$name" == "$cur"* ]]; then
                COMPREPLY+=("$name")
            fi
        done <<<"${model_names[*]}"
    )
}

# Register the completion function with bash-completion
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#Note that this script assumes that you have already installed and enabled `bash-completion`. If you haven't, you can follow [this guide](https://askubuntu.com/a/136425) to install it on Ubuntu-based systems.


#!/bin/bash

_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Trigger condition: only offer completions for 'run' subcommand
    if [[ "$prev" == "run" ]]; then
        # Model retrieval: capture the output of `ollama list` into a variable
        opts=$((ollama list) 2>/dev/null || true)

        # Prefix filtering and sorting: use compgen to generate completions that start with current word (cur)
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    fi
}
complete -F _ollama ollama  # Register the completion function for 'ollama' command

# Installation and activation instructions:
# Save this script in a location of your choice (e.g., ~/.bash_completion.d/ollama)
# Add `source ~/.bash_completion.d/ollama` to your ~/.bashrc file
# Then, open a new terminal or source the updated bash configuration (`source ~/.bashrc`)
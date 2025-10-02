#!/usr/bin/env bash

# Bash completion for ollama run command
_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # Check if the second word is exactly 'run'
    if [ "${words[1]}" == "run" ]; then
        # Get model names from ollama list, skipping the header and sorting uniquely
        COMPREPLY=( $(compgen -W "$(ollama list | sed 1d | awk '{print $1}' | sort -u)" -- "${words[cword]}") )
    fi
} && complete -F _ollama_run ollama


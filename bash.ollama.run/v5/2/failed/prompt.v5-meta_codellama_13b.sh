#!/bin/bash

_ollama_run () {
    local cur prev opts

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Targeted triggering: only activate for the word immediately following 'run'
    if [[ "$prev" != "run" ]]; then
        return 0
    fi

    # Get list of local models from `ollama list` output
    opts=$(ollama list | awk '{print $1}' | grep -v NAME)

    # Filter suggestions based on current word being completed
    COMPREPLY=($(compgen -W "$opts" -- "$cur"))

    return 0
}
complete -F _ollama_run ollama


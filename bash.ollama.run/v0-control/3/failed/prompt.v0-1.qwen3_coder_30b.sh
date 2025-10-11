#!/bin/bash

# Bash completion function for `ollama run <model>`
_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # If we're completing the command itself, return early
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=()
        return 0
    fi

    # If we're completing the model name (after 'ollama run')
    if [[ $cword -gt 2 ]] && [[ "${words[1]}" == "run" ]]; then
        # Get list of models from ollama list, skipping header line
        local models
        models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}' 2>/dev/null)

        # If we got models, complete them
        if [[ -n "$models" ]]; then
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
        fi
    fi
}

# Register the completion function for the 'ollama' command
complete -F _ollama_run ollama

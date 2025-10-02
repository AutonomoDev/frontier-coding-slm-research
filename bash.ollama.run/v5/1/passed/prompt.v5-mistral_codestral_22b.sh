#!/usr/bin/env bash

# This is a Bash script for auto-completion in `ollama run`. It provides model name suggestions from the output of `ollama list` command.

_ollama_run() {
    local cur prev words cword

    # Fallback if _get_comp_words_by_ref is missing or fails
    if ! type -t _get_comp_words_by_ref &>/dev/null; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
    else
        _get_comp_words_by_ref -n : cur prev words cword
    fi

    # Check if the current word is directly following 'run'
    if [ "${prev}" = "run" ]; then
        local models=()
        mapfile -t models < <(ollama list | tail -n +2 | awk '{print $1}')
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

# Register the completion function
complete -F _ollama_run ollama


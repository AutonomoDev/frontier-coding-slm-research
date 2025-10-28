#!/bin/bash

# Function for ollama run command completions
_ollama_completions() {
    # Check if the current word is ollama and the previous word is run
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Get the current and previous words using _get_comp_words_by_ref
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse the ollama list command to get a list of models
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort the models and use compgen to generate completions for the current word
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Fix colons in completions
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the _ollama_completions function for ollama command completions
complete -F _ollama_completions ollama

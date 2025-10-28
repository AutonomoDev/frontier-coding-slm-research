#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# Here is a sample bash completion script for the `ollama run` command:

_ollama_completions() {
    # Check if ollama is installed
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Check if enough arguments are present
    if [[ $COMP_CWORD -lt 2 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Indexing: check if ollama is the first argument and run is the second
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Colons: use _get_comp_words_by_ref -n : to set the current and previous words
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Fall back to COMP_WORDS if _get_comp_words_by_ref is not available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse the output of ollama list to get the model names
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Completions: sort the model names and use compgen to generate the completions
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Fix colons: if __ltrim_colon_completions is available, use it to trim the colon from the completion
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function with the ollama command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Note: This script assumes that the `ollama` command is installed and that it has a `list` subcommand that outputs the available models in the format `NAME ID SIZE MODIFIED`. If your version of `ollama` is different, you may need to modify the parsing logic in the script.

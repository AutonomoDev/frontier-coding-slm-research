#! /usr/bin/env bash

_ollama_completions() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur:_get_comp_words_by_ref -n :prev:_get_comp_words_by_ref -n :words:_get_comp_words_by_ref -n :cword:

    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local models=()

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models from ollama
    while IFS= read -r line; do
        if [[ "$line" != NAME* ]]; then  # Skip header line
            model=$(echo "$line" | awk '{print $1}')
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    local IFS=$'\n' COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

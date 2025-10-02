#!/usr/bin/env bash

# Bash completion for 'ollama run' command.
#
# This script provides autocompletion suggestions for model names in the
# `ollama run <model>` command based on the output of `ollama list`.
#
# The completion is triggered only when the word immediately following `run` is to be completed.

_ollama_run() {
    local cur prev words cword
    # Try using _get_comp_words_by_ref if available, else fallback to manual assignment.
    if ! compopt +o nospace &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
        cur="${words[cword]}"
        prev="${words[cword-1]}"
    fi

    # Ensure we're completing the word after 'ollama run'.
    if [[ ${#words[@]} -gt 2 && "${words[0]}" == "ollama" && "${prev}" == "run" ]]; then
        local models=()
        # Fetch model names from `ollama list`, skipping header line.
        ollama list | grep -v '^NAME' | cut -d ' ' -f1 | while read -r name; do
            [[ -n "$name" ]] && models+=("$name")
        done

        # Filter models based on current input and avoid duplicates.
        COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    fi
}

# Register the completion function for 'ollama run'.
complete -F _ollama_run ollama

# Explanation:
# 1. The script defines a completion function `_ollama_run` that checks if the command line is in the form `ollama run ...`.
# 2. It fetches model names from `ollama list`, filtering out the header and any empty lines.
# 3. The `compgen -W` command generates matches for the current word (`$cur`) based on the available models, ensuring uniqueness and correct partial matching.
# 4. The completion is registered with `complete` to trigger this function when completing `ollama`.


#!/bin/bash

# This is an example of a Bash completion function for 'ollama run <model>'.
_ollama() {
    local cur prev words cword split comp

    # Use _get_comp_words_by_ref to get the current word and previous one.
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref cur prev words cword
    else
        # Fallback for systems without _get_comp_words_by_ref
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the previous word is "run", and the command is "ollama".
    if [ "$prev" = "run" ] && [ "${words[0]}" = "ollama" ]; then
        # Run 'ollama list' and store its output in a variable.
        local models="$(ollama list 2>/dev/null)"

        if [[ -n $models ]]; then
            # Prepare an array with filtered & sorted model names.
            local matched_models=()
            while IFS= read -r line; do
                [[ $line =~ ^"$cur" ]] && matched_models+=("${line#* }")
            done <<< "$models"
            # Sort the array alphabetically.
            mapfile -t sorted_models < <(printf '%s\n' "${matched_models[@]}" | sort)

            # Use compgen to populate COMPREPLY with valid bash completions.
            if [[ ${#sorted_models[@]} -ne 0 ]]; then
                COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
            fi
        fi
    fi
}

# Attach the function to 'ollama'.
complete -F _ollama ollama

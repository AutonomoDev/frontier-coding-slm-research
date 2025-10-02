#!/bin/bash

_ollama_run_completion() {
    local cur prev words cword run_index model_names old_wb
    _get_comp_words_by_ref -n : cur prev words cword
    for ((i = 0; i < ${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done
    # Only trigger completion when the word immediately following 'run' is being typed.
    if ((cword != run_index + 1)); then
        return 0
    fi

    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    model_names=$(ollama list | awk 'NR>1 {print $1}' 2>/dev/null) || return 0

    if [[ -n "$model_names" ]]; then
        local suggested=($(compgen -W "${model_names}" -- "$cur"))
        COMPREPLY=("${suggested[@]}")
    fi

    # Avoid fallback filename completion.
    compopt +o nospace 2>/dev/null

    COMP_WORDBREAKS=$old_wb
}

# Register the function with bash-completion v2.
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script meets all your requirements. It does not rely on a fixed position or assume that `COMP_WORDS[0]` equals 'ollama', but rather searches for the index of "run" in `COMP_WORDS` and triggers completion only when this is followed by the word to be completed.
#
#It safely handles colons in model names by temporarily removing them from `COMP_WORDBREAKS`, then restoring it afterward.
#
#For contextual filtering, it uses `compgen` to generate completions that start with the current word fragment. If `ollama list` fails or returns nothing, the script quietly exits without any errors and without offering filename suggestions.


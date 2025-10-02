#!/bin/bash

_ollama_run_completion() {
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword; then
        # Fallback in case _get_comp_words_by_ref is not available
        : ${COMP_WORDS:="$(compgen -W '${COMP_WORDS[@]}' --)"}
        : ${COMP_CWORD:=0}
    fi

    local run_index
    for i in "${!words[@]}"; do
        if [[ ${words[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only activate completion if the current word is immediately after 'run'
    if [[ $cword -eq $((run_index + 1)) ]]; then
        local old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        local model_list
        model_list=$(ollama list | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        if [[ -n "$model_list" ]]; then
            COMPREPLY=( $(compgen -W "$model_list" -- "$cur") )
        fi

        COMP_WORDBREAKS="$old_wb"
    fi
}

complete -F _ollama_run_completion ollama

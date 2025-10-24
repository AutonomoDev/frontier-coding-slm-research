#!/bin/bash

# ollama run model completion function
_ollama_run_completion() {
    # Get the current word being completed (COMP_CWORD) and previous word (COMP_PREVIOUS_WORD)
    local cur prev words cword
    if type _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : -n = cur prev words cword
    else
        # Fallback for older versions of bash-completion
        local i=${COMP_CWORD}
        while [[ $i -ge 0 ]]; do
            if [[ "${COMP_WORDS[$i]}" == [^=]* ]]; then
                ((i--))
                continue
            fi
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[i]}"
            break
        done
    fi

    # Check if the completion should be triggered (previous word is "run" and command is "ollama")
    if [[ "$prev" != "run" || "${words[0]}" != "ollama" ]]; then
        return
    fi

    # Get the list of models from ollama list command
    local model_list=$(ollama list 2>/dev/null)
    if [[ -z "$model_list" ]]; then
        return
    fi

    # Extract model names and filter based on the current prefix (cur)
    COMPREPLY=()
    for model in $model_list; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=($model)
        fi
    done

    # Sort the completions alphabetically
    IFS=$'\n' COMPREPLY=($(sort <<<"${COMPREPLY[*]}"))
    unset IFS
}

# Attach the completion function to ollama run model argument
complete -F _ollama_run_completion ollama run

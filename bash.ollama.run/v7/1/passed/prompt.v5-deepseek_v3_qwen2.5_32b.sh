#!/bin/bash

# Define a function to handle completions for 'ollama run'.
_ollama_run_completion() {
    local cur prev cmd index words=0 models=()

    # Get the current and previous word using _get_comp_words_by_ref, with colon as part of word breaks.
    if [[ -n ${BASH_VERSION} && "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        # Fallback for older versions of bash-completion or incomplete setups.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cmd="${COMP_WORDS[@]:0:2}"
    fi

    # Find the index of 'run' in COMP_WORDS to ensure position-based completion.
    for ((i=0; i < ${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            cmd_index="$i"
            break
        fi
    done

    # Exit early if 'run' is not found or we're not completing after it.
    if [[ -z "$cmd_index" || ${cword} != $((cmd_index + 1)) ]]; then
        return
    fi

    # Retrieve the list of models from 'ollama list', parsing the first column.
    readarray -t model_lines < <(ollama list | awk 'NR>1 {print $1}')

    if [[ ${#model_lines[@]} -eq 0 ]]; then
        return
    fi

    # Deduplicate models (handle any duplicates in ollama list output).
    declare -A seen_models
    for model in "${model_lines[@]}"; do
        ((seen_models["$model"]++)) || models+=("$model")
    done

    # Handle colons properly by adjusting COMP_WORDBREAKS.
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Generate matches based on the current word (cur).
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Restore original COMP_WORDBREAKS before returning.
    COMP_WORDBREAKS=$old_wb

    # Avoid adding a space after completion when it's ambiguous.
    if [[ ${#COMPREPLY[@]} -gt 1 ]]; then
        compopt +o default 2>/dev/null
        compopt +o bashdefault 2>/dev/null
        compopt -o nospace 2>/dev/null
    fi
}

# Register the completion function for 'ollama run'.
complete -F _ollama_run_completion ollama


#! /usr/bin/env bash

_ollama_run_completion() {
    local cur prev words cword split
    _init_completion -s || return

    # Ensure the completion is triggered for the 'run' subcommand
    if [[ $cword -ne 2 ]] || [[ ${words[1]} != "run" ]]; then
        return
    fi

    # Get the list of local models
    local model_list=$(ollama list | awk 'NR>1 {print $1}')

    # Temporary remove colon from COMP_WORDBREAKS to handle model names with colons
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Generate completions based on the current word being typed
    COMPREPLY=()
    if [[ $cur == *:* ]]; then
        local cur_prefix=${cur%:*}
        local suggestions=$(echo "$model_list" | grep "^$cur_prefix:" || true)
    else
        local suggestions=$(echo "$model_list" | grep "^$cur" || true)
    fi

    # Restore COMP_WORDBREAKS to its original state
    COMP_WORDBREAKS=$old_wb

    # Generate unique, sorted suggestions using awk to dedupe
    if [[ -n $suggestions ]]; then
        COMPREPLY=( $(compgen -W "$(echo "$suggestions" | awk '!seen[$0]++')" -- "$cur") )
    fi

    # Ensure no options are set that would cause filename completion
    compopt -o nospace 2>/dev/null
}

# Register the completion function for the 'ollama run' command
complete -F _ollama_run_completion ollama


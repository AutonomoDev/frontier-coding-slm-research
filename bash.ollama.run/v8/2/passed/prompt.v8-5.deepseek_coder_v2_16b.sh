#!/usr/bin/env bash

# Bash completion for ollama run command

_ollama_run() {
    local cur prev words cword split=false
    _get_comp_words_by_ref -n : cur prev words cword

    # Save and restore COMP_WORDBREAKS to handle colons in model names
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    if [[ ${cword} -eq 2 ]]; then
        # Get the list of models using ollama list command
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
        
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Fallback to standard completion if not the correct position
        COMPREPLY=()
    fi

    # Restore COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}

# Register the function with the bash-completion framework
complete -F _ollama_run ollama


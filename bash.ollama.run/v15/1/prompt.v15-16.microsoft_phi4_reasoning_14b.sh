#!/bin/bash
# Function for ollama run command completion.
_ollama_run_completions() {
    # Temporarily adjust COMP_WORDBREAKS to handle model names with colons.
    local orig_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS="$orig_wb"

    # Only complete if the second word is "run".
    [[ "${COMP_WORDS[1]}" == "run" ]] || return 0

    # Dynamically fetch available models from 'ollama list' (skip header).
    local models
    models=$(ollama list | awk 'NR > 1 {print $1}')
    
    COMPREPLY=( $(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _ollama_run_completions ollama

#!/usr/bin/env bash
# Function to handle ollama completions
_ollama_completions() {
    # Only complete if first word is "run"
    if [[ ${COMP_WORDS[1]} != 'run' ]]; then return; fi
    
    local cur prev models

    # Temporarily remove colon from COMP_WORDBREAKS to handle model names with colons properly
    local old_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=$old_wordbreaks
    
    if [[ $prev == 'run' ]]; then
        # Retrieve model names using awk to get first column of list command, excluding header
        models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Use compgen to generate reply array
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the function as a completion for ollama command
complete -F _ollama_completions ollama


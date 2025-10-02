#!/bin/bash

# _ollama_completion function
_ollama_completion() {
    # Save and restore COMP_WORDBREAKS
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}   # Remove colon
    
    # Get current word and previous word
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    # Find the position of "run" in COMP_WORDS array
    local run_index
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ ${COMP_WORDS[i]} = "run" ]]; then
            run_index=$i
            break
        fi
    done
    
    # Only trigger completion when COMP_CWORD is exactly run_index + 1
    if (( cword == run_index+1 )); then
        # Get model names by removing the header, getting first field and filtering duplicates
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk 'BEGIN{RS=ORS="\n"} !seen[$0]++')
        
        # Provide model names as completion options
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Clear the completion options when not in right position
        COMPREPLY=()
    fi
    
    # Restore COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}

# Complete 'ollama run' command with the above function, but do NOT fall back to filenames
complete -F _ollama_completion ollama

# [[HUMAN COMMENTED-OUT]]
#The script defines a bash completion function `_ollama_completion` that handles colons and filters out duplicate completions. It uses helper functions when available (which is the case for most modern bash versions), but falls back to manual word detection otherwise. The function retrieves model names from `ollama list`, removes duplicates, then provides them as completion options if the previous word is "run".


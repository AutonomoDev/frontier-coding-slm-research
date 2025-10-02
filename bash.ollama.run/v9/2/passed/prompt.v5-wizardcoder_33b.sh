#!/bin/bash

# Define the _ollama_completions function.
_ollama_completions() {
    # Save original word break characters, modify them to remove colon, and then re-parse command line.
    local old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev
    # Restore original word break characters.
    COMP_WORDBREAKS=${old_wb}

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the function for ollama command.
complete -F _ollama_completions ollama


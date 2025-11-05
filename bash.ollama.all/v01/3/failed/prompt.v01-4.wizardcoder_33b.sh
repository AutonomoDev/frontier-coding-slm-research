#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# The following Bash function will provide tab completion for `ollama`. It fetches a list of all available models and completes based on these, sorting the results as it goes along.

_ollama_completions() 
{
    # Only complete if we are completing the "ollama" command.
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "${prev##*/}" ]] && return
    
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Fetch models if ollama is installed.
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completions.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort the completions and remove colons.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
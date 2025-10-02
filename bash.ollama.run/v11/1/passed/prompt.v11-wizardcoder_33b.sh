#!/bin/bash

_ollama_completions() {
    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        return 0
    fi
    
    # Handle the colon in word breaks
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || {
        # Fallback for systems without bash-completion loaded
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    if [[ "${prev}" != "run" ]]; then
        return 0
    fi

    # Generate completions for 'ollama run' command
    local models=$(ollama list | awk 'NR>1 {print $1}') || {
        COMPREPLY=()
        return 0
    }
    
    local sorted_matches=$(echo "$models" | grep "^$cur")
    
    if [[ -z "$sorted_matches" ]]; then
        COMPREPLY=()
        return 0
    fi

    COMPREPLY=( $(compgen -W "${sorted_matches}" -- "${cur}") )
    
    # Handle colon in completions properly
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama 


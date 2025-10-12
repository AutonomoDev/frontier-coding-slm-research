#!/bin/bash
# Function to generate completions for `ollama run`
_ollama_completions() {
    # Check if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    # Get current word and previous word (to handle colons correctly)
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword 

    # Check if ollama command exists
    command -v ollama &>/dev/null || { COMPREPLY=(); return; }
    
    # Get list of models and store in an array. Skip header line, extract first column
    local models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    
    # Generate completions using the compgen function
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Handle colons correctly in the completions
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama run
complete -F _ollama_completions ollama

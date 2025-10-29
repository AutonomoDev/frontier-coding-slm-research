# Activates only for "ollama run" command.
_ollama_completions() {
    local cur prev models
    
    # Check if the command is "ollama run". If not, return without triggering completions.
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    # Parse command line
    _get_comp_words_by_ref -n : cur prev
    
    # Check if ollama is installed. If not, return without triggering completions.
    ! command -v ollama &>/dev/null && { COMPREPLY=(); return; }
    
    # Get list of models from ollama list.
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  
    # If no models are available, return without triggering completions.
    if [ -z "$models" ]; then COMPREPLY=(); return; fi
    
    # Generate completions for the current word.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort the generated completion list.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    
    # Trim the colon-word prefix from the completion word.
    __ltrim_colon_completions "$cur"
}

# Register the function as a completion function for the "ollama run" command.
complete -F _ollama_completions ollama

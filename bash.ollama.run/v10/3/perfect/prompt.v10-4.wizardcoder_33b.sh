# Define a function for ollama completions
_ollama_completions() {
    local cur prev models COMP_WORDBREAKS_ORIG
    
    # Check if the first argument is "run". If not, return early.
    [[ ${COMP_WORDS[1]} != "run" ]] && return
    
    # Save original COMP_WORDBREAKS value
    COMP_WORDBREAKS_ORIG=${COMP_WORDS}
    
    # Temporarily remove ':' from COMP_WORDBREAKS and re-parse the command line using _get_comp_words_by_ref
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:} 
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS
    COMP_WORDS=${COMP_WORDBREAKS_ORIG}
    
    # Generate model names using `ollama list`. The awk command removes the first line (header) and selects only the model name column.
    models=$(ollama list | awk 'NR>1 {print $1}') 
    
    # Generate completions using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the function for ollama command.
complete -F _ollama_completions ollama

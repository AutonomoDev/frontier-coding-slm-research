# Function to complete 'ollama run' commands
_ollama_completions() {
    local cur prev
    
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
  
    # Try to handle colon correctly
    _get_comp_words_by_ref -n : cur prev || { 
        COMPREPLY=( $( compgen -W "$(ollama list 2>/dev/null | awk '{if (NR > 1) print $1}')" -- $cur ) )
    }  
    
    # Fix colon display issue
    __ltrim_colon_completions "$cur"
}

# Register function for completion of 'ollama run' commands
complete -F _ollama_completions ollama

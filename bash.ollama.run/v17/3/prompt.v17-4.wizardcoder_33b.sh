```bash
# The _ollama_completions function for 'ollama run' command
function _ollama_completions {
    # If subcommand is not "run", exit the function immediately to prevent interference with other commands
    if [[ ${COMP_WORDS[1]} != "run" ]]; then 
        return
    fi
  
    # Save original COMP_WORDBREAKS and temporarily remove colon
    local saved_comp_wordbreaks=$COMP_WORDBREAKS
    export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Get current word ($cur) and previous word ($prev) accounting for colon
    local cur prev cword
    _get_comp_words_by_ref -n : cur prev cword
  
    # Restore original COMP_WORDBREAKS
    export COMP_WORDBREAKS=$saved_comp_wordbreaks

    # Check if ollama command is available and fetch the list of models, skipping header line.
    if command -v ollama &>/dev/null; then 
        local models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Generate completion suggestions for current word accounting for colon and store in COMPREPLY array
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
  
    # Call the bash-completion helper function __ltrim_colon_completions to ensure suggestions are correctly displayed after a colon has been typed.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama
``` 


# Define a function to handle completions for the `ollama` command.
_ollama_completions() {
    # Check if the subcommand is "run". If not, return early without doing anything.
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Save the original COMP_WORDBREAKS to a local variable.
    local orig_COMP_WORDBREAKS="$COMP_WORDBREAKS"
    
    # Temporarily remove ':' from COMP_WORDBREAKS so that colons are not treated as word breaks.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse the command line to correctly handle model names containing colons.
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Immediately restore the original COMP_WORDBREAKS after re-parsing.
    COMP_WORDBREAKS="$orig_COMP_WORDBREAKS"
    
    # If the previous word is "run", generate completions for model names.
    if [[ "$prev" == "run" ]]; then
        # Retrieve the list of available models from `ollama list`, extracting only the first column starting from the second line.
        local models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Use compgen to generate completions for the current word based on the retrieved model names.
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function with the `ollama` command using bash-completion.
complete -F _ollama_completions ollama


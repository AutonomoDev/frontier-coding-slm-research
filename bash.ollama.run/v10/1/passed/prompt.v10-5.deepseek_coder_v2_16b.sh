# Generate completions for the `ollama run` command
_ollama_completions() {
    local cur prev words cword split
    _init_completion -s || return

    # Check if the previous word is "run"
    if [[ "$prev" != "run" ]]; then
        return
    fi

    # Handle colons in word breaks by temporarily removing them from COMP_WORDBREAKS
    local original_comp_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse the command line with colons considered part of words
    _get_comp_words_by_ref -n : cur prev
    
    # Restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS=$original_comp_wordbreaks

    # Get available model names
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions using compgen with quoted models to prevent word splitting
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama


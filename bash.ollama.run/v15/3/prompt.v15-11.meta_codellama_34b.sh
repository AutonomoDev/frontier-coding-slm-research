_ollama_run_completions() {
    # Temporarily modify COMP_WORDBREAKS to include colons
    local old_comp_wordbreaks="$COMP_WORDBREAKS"
    local cur prev
    
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_comp_wordbreaks"
    
    # Subcommand check (this must be after the colon handling)
    if [[ "$prev" != "run" ]]; then
        return 0
    fi
    
    # Generate list of models from ollama list
    local models="$(ollama list | awk 'NR>1 {print $1}')"
    
    COMPREPLY=($(compgen -W "$models" -- $cur))
}

complete -F _ollama_run_completions ollama
# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for the `ollama run` command:

_ollama_completions() {
    # Save original word breaks and remove colon from them
    local orig_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${orig_wordbreaks//:/}
    
    # Re-parse the command line with colons as non-word break
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word breaks
    COMP_WORDBREAKS=$orig_wordbreaks
    
    # If the previous word is "run", complete model names
    if [[ $prev == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script meets all the requirements specified. It checks for the "run" subcommand, handles colons in word breaks, and completes model names using `compgen` with `-W` option. The rest of the script ensures that the proper variables are used and word breaks are restored.

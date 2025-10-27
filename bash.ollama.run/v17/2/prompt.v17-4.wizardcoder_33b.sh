Here is an example implementation in bash for a script that fits these guidelines:

```bash
_ollama_completions() {
    # Check if subcommand is 'run' otherwise return
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return;
    fi

    local old_IFS=$IFS
    local IFS=$':'
    
    # Temporarily remove colon from COMP_WORDBREAKS and use _get_comp_words_by_ref to re-parse command line words.
    local tmp_COMP_WORDBREAKS=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref cur prev
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS=$tmp_COMP_WORDBREAKS
    
    IFS=$old_IFS

    # Check if ollama command exists.
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Fetch the list of models by running 'ollama list' and parse it to get model names only. 
    local models=$(ollama list | awk 'NR>1 {print $1}')
    
    # Generate completions using compgen and set it to COMPREPLY.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Call __ltrim_colon_completions to correctly handle colon-separated suggestions. 
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command.
complete -F _ollama_completions ollama
``` 


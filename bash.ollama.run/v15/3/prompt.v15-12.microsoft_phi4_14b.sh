```bash
_ollama_run_completions() {
    # Save the original COMP_WORDBREAKS and modify it to exclude colons
    local orig_wbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse current and previous words using the modified word break characters
    _get_comp_words_by_ref -n : cur prev
    
    # Restore the original COMP_WORDBREAKS immediately after parsing
    COMP_WORDBREAKS="$orig_wbreaks"

    # Check if the second word is "run" to trigger completions specifically for `ollama run`
    [[ "${COMP_WORDS[1]}" == "run" ]] || return

    # Fetch model names from `ollama list` and parse them
    local models
    models=$(ollama list | awk 'NR > 1 {print $1}')

    # Generate completions using compgen, based on the parsed model names
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for the `ollama run` command
complete -F _ollama_run_completions ollama
```

This script provides a robust Bash completion logic specifically tailored to handle model names with colons using the `ollama run` subcommand. It ensures correct behavior by temporarily modifying the word break characters, thereby allowing seamless integration and handling of complex input scenarios.


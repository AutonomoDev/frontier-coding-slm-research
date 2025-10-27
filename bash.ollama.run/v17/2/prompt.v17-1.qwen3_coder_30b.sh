```bash
_ollama_completions() {
    # Early exit if not called for 'ollama run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS
    local original_comp_wordbreaks="$COMP_WORDBREAKS"

    # Temporarily remove ':' from COMP_WORDBREAKS to correctly parse words
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

    # Re-parse words using _get_comp_words_by_ref with -n : to handle colons
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately
    COMP_WORDBREAKS="$original_comp_wordbreaks"

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Fetch list of models, skip header, extract first column (model name)
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions based on current input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Ensure correct display of completions after colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama
```


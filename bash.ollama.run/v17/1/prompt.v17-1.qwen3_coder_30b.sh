```bash
_ollama_completions() {
    # Early exit if not handling 'ollama run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"

    # Temporarily remove ':' from COMP_WORDBREAKS to correctly parse words
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"

    # Re-parse words using _get_comp_words_by_ref, treating ':' as part of a word
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately after parsing
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Fetch model list, skip header, extract first column (model name)
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate completions based on current input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Ensure proper display of completions after colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama
complete -F _ollama_completions ollama
```


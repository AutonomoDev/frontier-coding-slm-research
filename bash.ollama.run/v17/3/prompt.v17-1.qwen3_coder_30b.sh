```bash
_ollama_completions() {
    # Early exit if not called for 'ollama run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS and modify it to exclude ':'
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}

    # Re-parse words using the modified COMP_WORDBREAKS
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately after parsing
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Check if ollama is available
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Fetch and parse model list
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Ensure correct display of completions after colon
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


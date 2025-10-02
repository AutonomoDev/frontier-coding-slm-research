_ollama_completions() {
    # Check if ollama command exists
    type -P ollama &>/dev/null || return

    local cur prev words cword split

    # Handle colon-separated word breaks using _get_comp_words_by_ref
    # Fallback to standard COMP_WORDS parsing on systems without bash-completion
    if ! _get_comp_words_by_ref -n : cur prev; then
        _get_comp_words_by_ref cur prev
    fi

    # If the previous word is "run", generate completions for model names
    if [ "$prev" = "run" ]; then
        # Retrieve model names with ollama list, excluding header row
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}') || return

        # Filter matches and sort them
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Properly handle colon-separated completions display
        __ltrim_colon_completions "$cur"
    fi
}

# Register the function for ollama command
complete -F _ollama_completions ollama

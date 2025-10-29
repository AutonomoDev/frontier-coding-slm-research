# Function to handle completions for `ollama run` command
_ollama_completions() {
    # Check if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get the current and previous words with colons considered
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=(); return;
    fi

    # Parse models from `ollama list` command
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=(); return;
    fi

    # Generate completions based on the available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the generated completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completions if necessary
    __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama run` command
complete -F _ollama_completions ollama

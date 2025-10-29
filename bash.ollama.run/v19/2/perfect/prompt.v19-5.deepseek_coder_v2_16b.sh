# Bash completion function for `ollama run <model>`
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # If ollama command is not available, return immediately
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=();
        return;
    fi

    # Parse models from `ollama list`
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=();
        return;
    fi

    # Generate completions based on the available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completions if any are present
    __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama run`
complete -F _ollama_completions ollama

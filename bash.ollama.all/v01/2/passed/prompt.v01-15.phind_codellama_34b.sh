# [[HUMAN COMMENTED-OUT]]
# Here is the Bash completion function for `ollama`:

_ollama_completions() {
    # Validate command
    [[ "${COMP_WORDS[0]}" != "ollama" ]] && { COMPREPLY=(); return; }

    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fetch models
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort + trim
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This function first validates that the command is `ollama`. It then extracts the current and previous words using `_get_comp_words_by_ref`. It fetches the models by calling `ollama list` and generates completions with `compgen -W "$models" -- "$cur"`. The generated completions are sorted and trimmed by calling `printf | sort` and `__ltrim_colon_completions "$cur"`, respectively. Finally, it registers the completion function for `ollama`.

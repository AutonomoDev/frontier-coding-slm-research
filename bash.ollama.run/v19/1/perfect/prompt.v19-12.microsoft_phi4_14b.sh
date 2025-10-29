_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons (e.g., codellama:<TAB>)
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command exists
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=(); 
        return; 
    fi

    # Parse the available models from ollama list output
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then 
        COMPREPLY=(); 
        return; 
    fi

    # Generate completions based on the current input (cur)
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions alphabetically
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colon prefixes from completions if necessary
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script adheres to the requirements by checking only `COMP_WORDS[0]` and `COMP_WORDS[1]`, handling colons without additional checks, parsing models into a scalar string, generating completions with `compgen`, sorting them correctly, and trimming colon prefixes as needed. It also handles cases where `ollama` is not found or no models are available.

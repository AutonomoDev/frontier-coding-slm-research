_ollama_completions() {
    # Check if the current command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Set up variables to handle completion for colon-based inputs
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if the 'ollama' command is available, exit if not
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi

    # Get a list of models from the `ollama list` output
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # If there are no models, exit with an empty completion array
    if [ -z "$models" ]; then 
        COMPREPLY=()
        return
    fi

    # Generate possible completions based on the current word and available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the generated completions to ensure order consistency
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completion suggestions if necessary
    __ltrim_colon_completions "$cur"
}

# Register the function as a Bash completion entry point for 'ollama'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script is structured to meet all specified requirements, ensuring that it handles completion for `ollama run` with models listed by `ollama list`. It addresses scenarios involving command availability and model presence. The script avoids unnecessary complexity while providing robust handling of colons in the input.

_ollama_completions() {
    # Validate that the command is 'ollama' followed by a valid subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" || -z "${COMP_WORDS[1]}" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command is available, else return no completions
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch models from the output of `ollama list`, skipping the header line
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Return no completions if there are no models
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions based on the current input and available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions to ensure consistent order
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from the completion suggestions for consistency
    __ltrim_colon_completions "$cur"
}

# Bind the function to 'ollama' command for Bash completion
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This Bash function provides tab completion support for the `ollama` CLI tool. It ensures that completions are available only when the user types `ollama` followed by a valid subcommand and argument, such as a model name. The function handles various scenarios including checking if `ollama` is installed, ensuring there's no empty model list, and sorting completion suggestions for consistent output.

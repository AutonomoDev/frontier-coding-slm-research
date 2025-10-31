_ollama_completions() {
    # Validate the command to ensure it's 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Extract current and previous words for completion
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command exists
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi

    # Fetch the list of models from 'ollama'
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Handle empty or absent model lists
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions for the current word against available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort and trim colon in model names (e.g., 'codellama:<TAB>')
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 
# 1. **Command Validation**: The function first checks if the command being completed starts with `ollama run`. If not, it exits early.
# 
# 2. **Extract Current and Previous Words**: Uses `_get_comp_words_by_ref` to get the current word (`cur`) and previous word (`prev`). This is crucial for determining what completion should be generated based on user input so far.
# 
# 3. **Check Command Existence**: Verifies if `ollama` command exists in the system's PATH. If not, it exits early without generating any completions.
# 
# 4. **Fetch Models**: Uses `ollama list` to retrieve a list of models available for completion. It parses this output using `awk` to extract only the model names (skipping header lines with `tail -n +2`).
# 
# 5. **Handle Empty Model List**: If no models are found, it exits early to avoid errors in subsequent operations.
# 
# 6. **Generate Completions**: Uses `compgen` with `-W "$models"` to generate possible completions based on the current word input by the user (`$cur`).
# 
# 7. **Sort and Trim Colons**: Sorts the list of potential completions for consistent ordering and trims any leading colons in model names using `__ltrim_colon_completions`, which is necessary for models prefixed with a colon like `codellama:`.
# 
# 8. **Register Completion Function**: Finally, it registers `_ollama_completions` to handle completion requests when the user invokes the `ollama` command.

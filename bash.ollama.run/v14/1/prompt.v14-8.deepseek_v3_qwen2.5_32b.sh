_ollama_completions() {
    # Check if the current command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if ollama is installed to avoid errors
    command -v ollama &>/dev/null || {
        COMPREPLY=()
        return 0
    }

    # Get the list of available models, skipping header and extracting first column (model name)
    local model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models are found or command fails, exit early
    [[ -z "$model_list" ]] && {
        COMPREPLY=()
        return 0
    }

    # Generate completions based on the current prefix (cur)
    local model_completions=$(compgen -W "$model_list" -- "$cur")

    # Set COMPREPLY to match the user's input, with case-insensitive completion
    COMPREPLY=($(compgen -W "$model_completions" -- "$cur"))

    # Handle colon in completions (e.g., 'codellama:' should autocomplete)
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 1. **Command Check**: Ensures that the completion is only triggered when `ollama run` is typed.
# 2. **Colon Handling**: Uses `_get_comp_words_by_ref -n :` to prevent splitting on colons and `__ltrim_colon_completions` to correctly process model names with colons (e.g., `codellama:13b`).
# 3. **Model Parsing**: Filters out the header from `ollama list`, extracts only the model names, and handles cases where no models are found or the command is not available.
# 4. **Completions Generation**: Uses `compgen -W` to filter and sort the completions based on user input.
# 
# This script ensures robustness by handling edge cases (no models, missing command) and correctly managing model names with special characters like colons.


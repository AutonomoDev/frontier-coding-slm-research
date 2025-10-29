_ollama_completions() {
    # Validate command structure: must start with 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    # Extract current and previous words for completion
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Check if 'ollama' command is available
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=(); 
        return;
    fi

    # Fetch model names using 'ollama list', ignoring the first line
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Return if no models are found
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completion matches for the current word from available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort and trim the completions, especially handling colons in model names
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Register the function as a completion handler for 'ollama'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script sets up Bash tab completion for `ollama run <model>`. It first checks if the command structure is correct and extracts necessary words. It verifies if the `ollama` binary exists, retrieves available models by running `ollama list`, generates potential completions from these models, sorts them, and adjusts for special characters like colons in model names. The script ensures graceful handling of cases where no models are found or the `ollama` command is missing.

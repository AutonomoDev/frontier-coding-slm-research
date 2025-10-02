_ollama_completions() {
    # Check if the first word is "ollama" and the previous word is "run"
    if [[ "${COMP_CWORD}" -ne 2 || "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[0]}" != "ollama" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle colons in command words by using _get_comp_words_by_ref if available
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Proceed only if the previous word is "run"
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if 'ollama' command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Read the model names from `ollama list`
    local models=()
    local line
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip header and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED"* || -z "$line" ]]; then
            continue
        fi
        # Extract the first column which is the model name
        local model_name
        model_name=$(echo "$line" | awk '{print $1}')
        models+=("$model_name")
    done < <(ollama list 2>/dev/null)

    # If no models were found, return an empty completion array
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matches based on the current word
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches and generate completion suggestions
    COMPREPLY=( $(compgen -W "$(printf '%s\n' "${matches[@]}" | sort)" -- "$cur") )

    # Fix colon handling in completions to ensure correct display after colons
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

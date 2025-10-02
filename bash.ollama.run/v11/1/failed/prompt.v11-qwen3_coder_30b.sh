_ollama_completions()
{
    local cur prev words cword
    # Use _get_comp_words_by_ref to properly handle colons in words
    # The -n : flag tells it to not split on ':'
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after "ollama run"
    if [[ "${words[0]}" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models, skip header line, extract first column
    local models=()
    while IFS= read -r line; do
        # Skip empty lines and header
        if [[ -z "$line" ]] || [[ "$line" == "NAME"* ]]; then
            continue
        fi
        # Extract first field (model name) from the line
        local model_name=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model_name" ]]; then
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null)

    # If no models found, return early
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Build sorted matches based on current input
    local sorted_matches=""
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            sorted_matches="$sorted_matches $model"
        fi
    done

    # Sort the matches and generate completions
    if [[ -n "$sorted_matches" ]]; then
        sorted_matches=$(echo "$sorted_matches" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    else
        COMPREPLY=()
    fi

    # Critical: trim colon completions to avoid duplicate display
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama


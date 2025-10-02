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

    # Only complete after 'ollama run'
    if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models, skip header, extract first column
    local models=()
    local model
    while IFS= read -r line; do
        # Skip empty lines and header
        if [[ -z "$line" ]] || [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
            continue
        fi
        # Extract first field (model name) from the line
        model=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model" ]]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # If no models found, return empty reply
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Match models that start with current input
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches
    IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
    unset IFS

    # Generate completions
    if [[ ${#sorted_matches[@]} -gt 0 ]]; then
        COMPREPLY=($(compgen -W "${sorted_matches[*]}" -- "$cur"))
    else
        COMPREPLY=()
    fi

    # Trim colons from the beginning of completions to avoid display issues
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

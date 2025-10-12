_ollama_completions()
{
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colons in model names
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse ollama list output
    local models=()
    while IFS= read -r line; do
        # Skip header line
        if [[ "$line" == "NAME"* ]]; then
            continue
        fi
        # Extract first column (model name)
        local model_name=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model_name" ]]; then
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null)

    # Generate completions
    if [[ ${#models[@]} -gt 0 ]]; then
        COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
        # Sort completions
        IFS=$'\n' COMPREPLY=($(sort <<<"${COMPREPLY[*]}"))
    else
        COMPREPLY=()
    fi

    # Fix colon handling
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

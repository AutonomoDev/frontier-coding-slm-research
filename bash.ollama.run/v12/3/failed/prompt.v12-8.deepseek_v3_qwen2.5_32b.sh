_ollama_completions() {
    # Check if the first word is "ollama" and previous command part is "run"
    local words=(${COMP_WORDS[@]})
    if [[ "${words[0]}" != "ollama" || "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle colons in model names (critical for completion after colon)
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    local models=()
    local matches=()

    # Check if ollama command exists and fetch model names from 'ollama list'
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip header (NAME ID SIZE MODIFIED) and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED"* ]] || [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi

        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    # If no models, return empty completion
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matching models based on current input (cur)
    for model in "${models[@]}"; do
        if [[ "$model" == $cur* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches and generate completion suggestions
    local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Essential: fix colon-related display issues (without this, no suggestions after ':')
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama

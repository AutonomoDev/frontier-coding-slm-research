# Function to generate completions for ollama run command
_ollama_completions() {
    local cur prev matches sorted_matches
    COMPREPLY=()

    # Get the current and previous words using COMP_WORDS if _get_comp_words_by_ref is not available
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # If the previous word is not "run" or the first word is not "ollama", return early
    if [[ "$prev" != "run" || "$1" != "ollama" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Run ollama list and read the output line by line
    while IFS= read -r line; do
        # Skip header and empty lines
        if [[ "$line" =~ ^NAME[[:space:]] ]]; then
            continue
        fi
        # Extract model names (first column) using awk or similar
        model_name=$(echo "$line" | awk '{print $1}')
        models+=("$model_name")
    done < <(ollama list 2>/dev/null)

    # If no models are found, return early
    if [[ -z "${models[@]}" ]]; then
        COMPREPLY=()
        return
    fi

    # Generate matches for completion
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Set COMPREPLY with compgen
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Ensure suggestions appear correctly after colons
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

_ollama_completions() {
    # Check if we are completing for the 'ollama' command with a subcommand 'run'
    local cur prev words cword
    if [[ "${COMP_CWORD}" -eq 1 ]]; then
        return
    fi

    # Use _get_comp_words_by_ref to get current and previous word correctly handling colons
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion, using standard COMP_WORDS
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Proceed only if the previous word is 'run'
    if [[ "${prev}" != "run" ]]; then
        return
    fi

    # Ensure ollama command exists before attempting to use it
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 1
    fi

    # Retrieve available models using 'ollama list'
    local model_list output matches sorted_matches
    model_list=$(ollama list)
    if [[ $? -ne 0 || -z "$model_list" ]]; then
        # Handle failure or empty response from ollama list gracefully
        COMPREPLY=()
        return 1
    fi

    # Parse the first column of output (model names) using awk, skipping header line
    output=$(echo "$model_list" | awk 'NR > 1 {print $1}')
    
    # Generate matches based on current input (cur)
    matches=($(compgen -W "${output}" -- "${cur}"))

    # Sort matches to ensure consistent order in suggestions
    sorted_matches=$(printf "%s\n" "${matches[@]}" | sort)

    # Set COMPREPLY with the sorted matches
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "${cur}") )

    # Handle colon-separated word completion display properly using __ltrim_colon_completions
    __ltrim_colon_completions "${cur}"
}

# Register the _ollama_completions function with 'complete' to handle completions for the 'ollama' command
complete -F _ollama_completions ollama

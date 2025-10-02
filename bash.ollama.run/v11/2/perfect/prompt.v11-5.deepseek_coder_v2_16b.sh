# Function to handle completions for the `ollama` command
_ollama_completions() {
    local cur prev words cword split
    if ! _get_comp_words_by_ref -n : cur prev; then
        compopt -o default
        COMPREPLY=()
        return 1
    fi

    # Check if the previous word is "run" and handle completions accordingly
    if [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Get model names from `ollama list` command
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion replies based on the current word ($cur)
    COMPREPLY=($(compgen -W "$(echo "${models}" | tr '\n' ' ')" -- "$cur"))

    # Handle colon-separated completions properly
    if [[ "${cur}" != :* ]]; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

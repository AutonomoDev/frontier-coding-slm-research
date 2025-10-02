# Function to handle completions for the `ollama` command
_ollama_completions() {
    # Check if the command is "ollama" and previous word is "run"
    local cmd="${COMP_WORDS[0]}"
    if [[ "$cmd" != "ollama" || "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colons in model names correctly by using _get_comp_words_by_ref with -n : flag
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion loaded
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the ollama command exists before calling it
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve model names using `ollama list` and parse with awk/while loop to extract first column, skipping header
    local models
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Handle empty or failed ollama list output gracefully
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Filter matches using array iteration and pattern matching against `$cur`
    local matches=()
    while IFS= read -r model; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done <<< "$models"

    # Sort matches and use `compgen` to generate COMPREPLY
    local sorted_matches
    sorted_matches=$(printf "%s\n" "${matches[@]}" | sort)
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # CRITICAL: Call __ltrim_colon_completions to properly handle colon-separated completions display
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

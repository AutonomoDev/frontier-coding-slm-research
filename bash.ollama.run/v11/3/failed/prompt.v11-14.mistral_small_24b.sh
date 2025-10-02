# Function to handle completions for the `ollama` command
_ollama_completions() {
    local cur prev

    # Check if bash-completion is available and use _get_comp_words_by_ref with -n : flag
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if the command is "ollama" and previous word is "run"
    if [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve model names using `ollama list`
    local models
    if command -v ollama >/dev/null 2>&1; then
        models=$(ollama list | awk 'NR>1 {print $1}')
    else
        COMPREPLY=()
        return 0
    fi

    # Handle empty or failed output gracefully
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Filter matches using array iteration and pattern matching against `$cur`
    local matches=()
    for model in $models; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches and use compgen to generate COMPREPLY
    local sorted_matches
    IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
    unset IFS
    COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

    # CRITICAL: Handle colon-separated completions display properly
    __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama

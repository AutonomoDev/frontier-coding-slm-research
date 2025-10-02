_ollama_completions() {
    local cur prev models matches line model

    # Handle colons
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete model names after "ollama run"
    if [ "$prev" != "run" ]; then
        COMPREPLY=()
        return 0
    fi

    # Check if ollama command exists
    type -P ollama &> /dev/null || return 0

    # Get model names from `ollama list`
    models=($(ollama list 2>/dev/null | {
        read header
        while read line; do
            [[ -n $line ]] && printf '%s\n' "${line%% *}"
        done
    }))

    # If no models, set COMPREPLY=() and return
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return 0
    fi

    # Find matches
    for model in "${models[@]}"; do
        [[ $model == "$cur"* ]] && matches+=("$model")
    done

    # Sort and set COMPREPLY
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Fix colon completion
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama

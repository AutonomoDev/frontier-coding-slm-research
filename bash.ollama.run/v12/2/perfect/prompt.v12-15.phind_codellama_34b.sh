_ollama_completions() {
    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        return
    fi

    # Check if first word is "ollama" and second word is "run"
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    if [ "$prev" != "run" ]; then
        COMPREPLY=()
        return
    fi

    # Get model names from 'ollama list'
    local models=( )
    while IFS= read -r line; do
        if [[ $line = NAME* ]]; then
            continue
        elif [[ -z $line ]]; then
            continue
        fi
        models+=( "${line%% *}" )
    done < <(ollama list 2>/dev/null)

    # No matches if no models
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Find matching model names
    local matches=( )
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=( "$model" )
        fi
    done

    # Sort matches and set COMPREPLY
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Fix colon completion
    __ltrim_colon_completions "$cur"
} && complete -F _ollama_completions ollama

_ollama_completions() {
    local cur prev words cword models match sorted_matches
    
    if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    else
        _get_comp_words_by_ref -n : cur prev
    fi
    
    if [ "${COMP_WORDS[0]}" != 'ollama' ] || [ "$prev" != 'run' ]; then
        COMPREPLY=()
        return 0
    fi

    # Get model names from `ollama list` command.
    if command -v ollama &>/dev/null; then
        while read -r line; do
            [[ $line = NAME* ]] && continue # Skip header and empty lines.
            models+=($(echo $line | awk '{print $1}'))  # Get model names (first column).
        done < <(ollama list 2>/dev/null)
    else
        COMPREPLY=()
        return 0
    fi
    
    # If no models, set COMPREPLY and return.
    [ ${#models[@]} -eq 0 ] && COMPREPLY=() && return 0
    
    for model in "${models[@]}"; do
        [[ $model = $cur* ]] && matches+=($model) # Add to matches if starts with cur.
    done
    
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)  # Sort the matches.
    
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") ) # Set COMPREPLY.
    __ltrim_colon_completions "$cur" # Fix colon splitting issue.
}

complete -F _ollama_completions ollama  # Register the function for ollama completion.

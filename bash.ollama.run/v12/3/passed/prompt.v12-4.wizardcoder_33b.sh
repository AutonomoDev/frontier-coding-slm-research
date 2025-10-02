_ollama_completions() {
    local cur prev models matches sorted_matches
    COMPREPLY=()

    # Check if the command exists and get current and previous words
    if ! command -v ollama &>/dev/null || [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[COMP_CWORD-1]}" != "run" ]]; then
        return
    fi
    
    # Get the current word and previous word separated by colon
    if  ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    # Get model names from ollama list, skipping the header and empty lines
    while IFS= read -r line; do
        if [[ "$line" =~ NAME ]]; then continue; fi  # Skip Header
        if [ -n "$line" ]; then  # Skip Empty Lines
            model=$(echo $line | awk '{print $1}')  # Get Model Name
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)
    
    if (( "${#models[@]}" == 0 )); then return; fi  # No Matches

    for model in "${models[@]}"; do
        [[ "$model" == $cur* ]] && matches+=("$model")  # Only Suggest if it Starts with Current Word
    done
    
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)  # Sort Matches
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )  
    __ltrim_colon_completions "$cur"  # Fix Suggestions after Colon
}

complete -F _ollama_completions ollama  # Register Function

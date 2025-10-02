_ollama_completions() {
    # Check if we're completing 'ollama run'
    local cur prev words cword
    if [[ "${#COMP_WORDS[@]}" -ne 3 ]]; then
        return
    fi

    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion framework
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    # Only proceed if the previous word is 'run'
    [[ "${prev}" != "run" ]] && return

    # Ensure ollama command exists before attempting to list models
    if ! command -v ollama &> /dev/null; then
        return
    fi

    # Retrieve and parse model names from `ollama list`
    local models=()
    local line matches sorted_matches
    while IFS=$'\n' read -r line; do
        if [[ "${line}" =~ ^NAME ]]; then
            continue  # Skip header row
        fi
        
        # Extract the first column (model name) using awk
        model_name=$(echo "$line" | awk '{print $1}')
        
        models+=("$model_name")
    done < <(ollama list)

    # Filter matches based on the current word being typed
    for match in "${models[@]}"; do
        if [[ "$match" == "${cur}*" ]]; then
            matches+=("$match")
        fi
    done

    # Sort matches and prepare them for completion suggestion
    IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
    COMPREPLY=($(compgen -W "$(IFS=' '; echo "${sorted_matches[*]}")" -- "$cur"))

    # Handle colon-completion display correctly
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

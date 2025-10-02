_ollama_completions() {
    # Ensure we're completing 'ollama run' and not other subcommands
    local command=${COMP_WORDS[0]}
    if [[ $command != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colon in model names correctly (like codellama:)
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete models after 'ollama run'
    if [[ $prev != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Check ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi

    local models=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and header row
        case $line in
            "NAME ID SIZE MODIFIED"|'')
                continue ;;
            *)
                model=$(echo $line | awk '{print $1}')
                if [[ ! -z "$model" ]]; then models+=("$model"); fi ;;
        esac
    done < <(ollama list 2>/dev/null)

    # If no models found, return empty completions
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    local matches=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches alphabetically for better readability
    IFS=$'\n' sorted_matches=($(printf '%s\n' "${matches[@]}" | sort))
    unset IFS

    COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") )

    # Fix colon handling to show completions properly after colons (e.g., codellama:)
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

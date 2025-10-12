# Bash completion function for ollama run command
# Only activates when command is "ollama run"

function _ollama_completions() {
    # Check if command is not "ollama" or first argument is not "run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    # Get model names from ollama list command
    local models=()

    # Check if ollama is installed
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Get ollama list output, ignoring errors
    local ollama_list=$(ollama list 2>/dev/null)

    # Parse models from output, skipping header line
    if [[ -n "$ollama_list" ]]; then
        IFS=$'\n'
        local lines=($ollama_list)
        for ((i=${#lines[@]} -1; i>=0; i--)); do
            # Skip header line "NAME ID SIZE MODIFIED"
            [[ "${lines[i]}" == "NAME"* ]] && continue
            # Extract first column (model name) using awk
            local model=$(echo "${lines[i]}" | awk '{print $1}')
            models=($model ${models[@]})
        done
    fi

    # Handle colon in model names
    _get_comp_words_by_ref -n : cur prev

    # Generate completions for models matching current word
    if [[ "$cur" ]]; then
        local matches=$(compgen -W "${models[*]}" -- "$cur")
        COMPREPLY=($(printf '%s\n' $matches | sort))
    else
        COMPREPLY=(${models[@]})
    fi

    # Fix colon handling in completions
    __ltrim_colon_completions "$cur"
}

# Register completion function for ollama command
complete -F _ollama_completions ollama

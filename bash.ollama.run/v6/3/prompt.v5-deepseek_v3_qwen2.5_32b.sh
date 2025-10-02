# Start by ensuring that the script is compatible with Bash and the `bash-completion` v2 framework.
#
# The script defines a completion function for the `ollama run` command, providing model names as autocompletions.

_ollama_run_completion() {
    local cur prev words cword split

    # Fallback to manual extraction of 'cur' (current word) and 'prev' (previous word)
    # in case '_get_comp_words_by_ref' is not available.
    if _completion_loader; then
        # Try using '_get_comp_words_by_ref', which is more reliable for handling word splitting.
        if ! _get_comp_words_by_ref -n : cur prev words cword; then
            echo "Failed to load completion loader." >&2
            return 1
        fi
    else
        # Fallback approach: Manually parse 'COMP_WORDS' and 'COMP_CWORD'.
        local i=0
        for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
            if [[ "${COMP_WORDS[i]}" == "ollama" ]]; then
                break
            fi
        done

        # Check that the command starts with 'ollama' and has a 'run' subcommand.
        if [[ $i -ge ${#COMP_WORDS[@]} || "${COMP_WORDS[$i+1]}" != "run" ]]; then
            return 0
        fi

        prev="${COMP_WORDS[i+1]}"
        cur="${COMP_WORDS[ i + $((${cword} - i)) ]}"
    fi

    # Check that the first word is 'ollama' and the previous word is exactly 'run'.
    if [[ $prev != "run" ]]; then
        return 0
    fi

    # Get available models by running 'ollama list' and extracting only the model names.
    local models=()
    while IFS= read -r line; do
        if [[ "$line" == NAME* ]]; then
            continue
        fi
        models+=("$(echo $line | cut -d' ' -f1)")
    done < <(ollama list)

    # Ensure unique entries by converting to an associative array.
    declare -A model_map
    for m in "${models[@]}"; do
        model_map["$m"]=1
    done

    local completions=()
    for key in "${!model_map[@]}"; do
        if [[ "$key" == *"$cur"* ]]; then  # Simple substring matching.
            completions+=("$key")
        fi
    done

    # Fill 'COMPREPLY' with the filtered list of models.
    COMPREPLY=("${completions[@]}")

    return 0
}

# Register the completion function for the 'ollama run' command.
complete -F _ollama_run_completion ollama


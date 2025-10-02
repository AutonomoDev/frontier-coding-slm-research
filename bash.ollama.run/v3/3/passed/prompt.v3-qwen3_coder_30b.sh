_ollama_run_completion() {
    local cur prev words cword
    # Fallback for _get_comp_words_by_ref if missing
    if declare -f _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only trigger completion after `ollama run`
    if [[ "$prev" != "run" ]] || [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return 0
    fi

    # Get model list once, safely
    local models output
    output=$(ollama list 2>/dev/null)
    if [[ -z "$output" ]]; then
        return 0
    fi

    # Extract model names (first column) and store in array
    while IFS= read -r line; do
        [[ -n "$line" ]] && models+=("$(echo "$line" | awk '{print $1}')")
    done <<< "$output"

    # Filter and sort matching models
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    if [[ ${#matches[@]} -gt 0 ]]; then
        IFS=$'\n' sorted=($(sort <<<"${matches[*]}"))
        COMPREPLY=("${sorted[@]}")
    fi
}

complete -F _ollama_run_completion ollama

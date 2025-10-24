_ollama_run_completion() {
    local cur prev words cword
    _init_completion || return

    # Only provide completions when the second word is 'run'
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Get the current input being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch list of models, skip header, extract first column (model names)
    local models=()
    while IFS= read -r line; do
        # Skip the header line
        if [[ "$line" == NAME* ]]; then
            continue
        fi
        # Extract the first field (model name) using awk
        local model_name=$(echo "$line" | awk '{print $1}')
        if [[ -n "$model_name" ]]; then
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null)

    # Filter models based on current input
    local completions=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            completions+=("$model")
        fi
    done

    # Remove duplicates by converting to associative array and back
    local unique_completions=()
    declare -A seen
    for item in "${completions[@]}"; do
        if [[ -z "${seen[$item]}" ]]; then
            seen[$item]=1
            unique_completions+=("$item")
        fi
    done

    # Set the completion results
    COMPREPLY=("${unique_completions[@]}")
}

# Register the completion function for `ollama`
complete -F _ollama_run_completion ollama


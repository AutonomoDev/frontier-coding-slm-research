_ollama_run_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local models=()

    # Try to get list of models, silently fail if ollama is not available
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return 0
    fi

    # Split output into array of model names (space or newline separated)
    while IFS= read -r line; do
        for model in $line; do
            [[ -n "$model" ]] && models+=("$model")
        done
    done <<< "$list_output"

    # Generate completions matching current prefix
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 
# 1. Save the script to a file, e.g., `_ollama_completion.sh`.
# 2. Source it in your current shell session:
#    ```bash
#    source _ollama_completion.sh
#    ```
# 3. Optionally, add the source line to your `~/.bashrc` or `~/.bash_profile` to make it permanent.
# 
# > Note: Ensure `ollama` is in your `$PATH` and the command `ollama list` works before using this completion.

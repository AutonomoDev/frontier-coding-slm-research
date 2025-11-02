```bash
_ollama_run_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local models=()

    # Try to get models from ollama list, silently fail if command not found
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return 0
    fi

    # Split output into array, handling both newline and space-separated
    IFS=$'\n' read -r -d '' -a models <<< "$list_output"

    # Filter models by current prefix and add to COMPREPLY
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done
}

complete -F _ollama_run_completion ollama
```

### Installation Instructions

1. Save the script to a file, e.g., `_ollama_run_completion.sh`.
2. Source it in your current shell session:
   ```bash
   source _ollama_run_completion.sh
   ```
3. Optionally, add the source line to your `~/.bashrc` to make it permanent:
   ```bash
   echo 'source /path/to/_ollama_run_completion.sh' >> ~/.bashrc
   ```

> **Note:** Ensure `ollama` is in your `$PATH` and the `ollama list` command works as expected. The completion will only suggest models that match the current input prefix.


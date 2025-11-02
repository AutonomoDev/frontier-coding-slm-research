```bash
_ollama_run_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local models=()

    # Try to get models, silently fail if ollama is not available or errors
    local list_output
    list_output=$(ollama list 2>/dev/null) || return 0

    # Split output into array, handling both newlines and whitespace
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue
        # Split line by whitespace and add each word as a model
        for word in $line; do
            models+=("$word")
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

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama
```

### Installation Instructions

1. Save the script to a file, e.g., `_ollama_run_completion.sh`.
2. Source it in your current shell session:
   ```bash
   source /path/to/_ollama_run_completion.sh
   ```
3. Optionally, add the source line to your `~/.bashrc` or `~/.bash_profile` to make it persistent across sessions.

> ⚠️ Ensure `ollama` is in your `$PATH` and the command `ollama list` works before using this completion.


```bash
_ollama_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being completed
    local cmd="${COMP_WORDS[1]}"           # Second word (e.g., "run")

    # Only provide completions for `ollama run`
    if [[ "${COMP_WORDS[0]}" == "ollama" && "$cmd" == "run" ]]; then
        # Capture output of `ollama list` into a variable
        local models
        models=$(ollama list 2>/dev/null) || return 0  # Silent failure if command fails

        # Convert output into array (handles both newline and space-separated)
        local model_array=()
        while IFS= read -r line; do
            # Split line by whitespace and add each part
            for word in $line; do
                model_array+=("$word")
            done
        done <<< "$models"

        # Filter models that start with the current completion word
        local matches=()
        for model in "${model_array[@]}"; do
            if [[ "$model" == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        # Sort matches alphabetically
        IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
        unset IFS

        # Assign to COMPREPLY for bash completion
        COMPREPLY=("${sorted_matches[@]}")
    fi
}

# Register completion function for ollama
complete -F _ollama_completion ollama
```

### Installation Instructions:

1. Save this script to a file, e.g., `ollama-completion.sh`.
2. Add the following line to your `~/.bashrc`:
   ```bash
   source /path/to/ollama-completion.sh
   ```
3. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```


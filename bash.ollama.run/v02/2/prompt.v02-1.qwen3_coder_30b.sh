```bash
_ollama_completion() {
    local cur prev words cword
    _init_completion || return

    # Only complete after "ollama run"
    if [[ ${#COMP_WORDS[@]} -ge 3 && "${COMP_WORDS[1]}" == "run" ]]; then
        # Capture ollama list output into a variable
        local models_output
        models_output=$(ollama list 2>/dev/null) || return  # Silent failure if ollama list fails

        # Split output into array, handling both newlines and whitespace
        local models=()
        while IFS= read -r line; do
            # Split line by whitespace and add each word as a model
            for word in $line; do
                models+=("$word")
            done
        done <<< "$models_output"

        # Filter models matching the current word being completed (prefix)
        local cur_word="${COMP_WORDS[COMP_CWORD]}"
        local matches=()

        for model in "${models[@]}"; do
            if [[ "$model" == "$cur_word"* ]]; then
                matches+=("$model")
            fi
        done

        # Sort matches alphabetically
        if [[ ${#matches[@]} -gt 0 ]]; then
            IFS=$'\n' sorted=($(sort <<<"${matches[*]}"))
            unset IFS
            COMPREPLY=("${sorted[@]}")
        else
            COMPREPLY=()
        fi
    fi
}

# Register the completion function for ollama
complete -F _ollama_completion ollama
```

### Installation Instructions:

1. Save this script to a file, e.g., `ollama-completion.sh`.
2. Add the following line to your `~/.bashrc`:
   ```bash
   source /path/to/ollama-completion.sh
   ```
3. Reload your shell or run:
   ```bash
   source ~/.bashrc
   ```


_ollama_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being completed
    local cmd="${COMP_WORDS[1]}"           # Second word (e.g., "run")

    # Only complete after "ollama run"
    if [[ "${COMP_WORDS[0]}" == "ollama" && "$cmd" == "run" ]]; then
        # Capture ollama list output into a variable to avoid subshell issues
        local models_output
        models_output=$(ollama list 2>/dev/null) || return 0  # Silent failure

        # Split output into array, handling both newline and space-separated
        local models=()
        while IFS= read -r line; do
            # Split line by whitespace into individual model names
            for model in $line; do
                models+=("$model")
            done
        done <<< "$models_output"

        # Filter models matching current prefix and sort them
        local matches=()
        for model in "${models[@]}"; do
            if [[ "$model" == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        # Sort matches alphabetically (using printf and sort)
        if [[ ${#matches[@]} -gt 0 ]]; then
            IFS=$'\n' COMPREPLY=($(printf '%s\n' "${matches[@]}" | sort))
        else
            COMPREPLY=()
        fi
    fi
}

# Register completion function for ollama
complete -F _ollama_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save this script to `~/.ollama-completion.sh`
# 2. Add `source ~/.ollama-completion.sh` to your `~/.bashrc`
# 3. Run `source ~/.bashrc` to activate immediately

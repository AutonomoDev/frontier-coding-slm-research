```bash
# Bash-completion function for `ollama run <model>`
_ollama_run_completion() {
    # Check if we are completing after 'run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # If the current word is not completing after 'run', return early
    [[ "${#words[@]}" -ne 2 || "$prev" != "run" ]] && return

    # Capture the output of `ollama list` into a variable, and check if it succeeded
    local models
    if ! models=$(ollama list 2>/dev/null); then
        return  # Graceful failure: do nothing on error
    fi
    
    # Convert whitespace-separated model names to an array-like string
    IFS=' ' read -r -a model_array <<< "$models"

    # Filter and sort models based on the current completion word (cur)
    local suggestions=()
    for model in "${model_array[@]}"; do
        [[ "$model" == "$cur"* ]] && suggestions+=("$model")
    done

    # Sort the matched suggestions alphabetically
    IFS=$'\n' suggestions=( $(printf '%s\n' "${suggestions[@]}" | sort ) )

    # Populate COMPREPLY with the filtered and sorted model names
    COMPREPLY=("${suggestions[@]}")

    # Return to avoid further processing by bash completion
    return 0
}

# Associate the completion function with `ollama`
complete -F _ollama_run_completion ollama

```

### Installation/Activation Instructions:

1. Save the above script into a file, e.g., `/etc/bash_completion.d/ollama.bash`.
2. Ensure you have bash-completion installed and sourced in your `.bashrc` or equivalent.
3. Add this line to your `.bashrc` if not already present:
   ```bash
   source /etc/profile.d/bash_completion.sh
   ```
4. Reload the shell configuration with `source ~/.bashrc`.

This will enable autocompletion for `ollama run <model>` in Bash.


```bash
# Bash completion script for `ollama run <model>`

_ollama_run_completion() {
    local cur prev opts models

    # Get current word and previous word in the command line
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only provide completions for `run` subcommand
    if [[ ${#COMP_WORDS[@]} -eq 2 && "${prev}" == "run" ]]; then
        # Capture the output of 'ollama list'
        models=$(ollama list 2>/dev/null)

        # Check if models capture was successful and not empty
        if [[ $? -eq 0 && "$models" != "" ]]; then
            # Split models into an array, assuming whitespace or newline-separated entries
            IFS=$'\n ' read -rd '' -a model_array <<< "$models"

            # Filter matching models based on current prefix
            COMPREPLY=($(compgen -W "${model_array[*]}" -- "$cur"))
        fi
    fi

    return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# Installation Instructions:
# Save this script to a file named 'ollama-completion.sh'.
# Source it in your shell's startup configuration (e.g., .bashrc, .zshrc):
#   source /path/to/ollama-completion.sh
# Restart the shell or run `source ~/.bashrc` for changes to take effect immediately.
```

**Installation Instructions:**

1. Save the above script to a file named `ollama-completion.sh`.
2. Add the following line to your `.bashrc`, `.zshrc`, or equivalent shell configuration file:
   ```bash
   source /path/to/ollama-completion.sh
   ```
3. Reload your shell configuration by running `source ~/.bashrc` (or similar) in your terminal, or restart your shell session for the changes to take effect immediately.


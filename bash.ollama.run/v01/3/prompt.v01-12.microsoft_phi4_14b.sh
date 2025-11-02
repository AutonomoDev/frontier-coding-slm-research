```bash
# Bash completion function for `ollama run <model>`
_ollama_run_complete() {
    local cur prev words cword

    # Read the current input state
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if we are in the 'run' subcommand position and have at least one word before it
    if [[ $cword -eq 2 && $prev == run ]]; then
        local models=()
        
        # Attempt to get the list of models using `ollama list`
        mapfile -t models < <(ollama list 2>/dev/null) || return

        # Filter and suggest model names matching the current prefix
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

# Install instructions:
# 1. Save this script to a file, e.g., `ollama_bash_completion.sh`.
# 2. Source it in your shell configuration file (e.g., `.bashrc` or `.bash_profile`):
#    . /path/to/ollama_bash_completion.sh
# 3. Run `source ~/.bashrc || source ~/.bash_profile` to activate the completion immediately.

# Register the function for completion of 'ollama run'
complete -F _ollama_run_complete ollama
```

### Installation Instructions

1. Save this script to a file, e.g., `ollama_bash_completion.sh`.
2. Source it in your shell configuration file (e.g., `.bashrc` or `.bash_profile`):
   ```bash
   . /path/to/ollama_bash_completion.sh
   ```
3. Run `source ~/.bashrc || source ~/.bash_profile` to activate the completion immediately.

This setup ensures that the bash-completion for `ollama run <model>` is robust, portable, and works without external dependencies.


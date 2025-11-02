```bash
_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # Get the current word and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the command is `ollama run` and we are at the second argument position
    if [[ ${prev} == "run" ]]; then
        local models
        # Attempt to get the list of models from `ollama list`
        models=$(ollama list 2>/dev/null)

        if [[ $? -eq 0 && -n "$models" ]]; then
            # Split the output into an array, assuming models are separated by whitespace or newline
            IFS=$'\n' read -r -d '' -a model_array <<<"$models"
            unset IFS

            # Filter the models based on the current prefix
            COMPREPLY=( $(compgen -W "${model_array[@]}" -- "$cur") )
        fi
    fi

    return 0
}

complete -F _ollama_run ollama
```

### Installation Instructions:
1. Save the above script to a file, e.g., `ollama-completion.bash`.
2. Source the script in your shell configuration file (e.g., `~/.bashrc` or `~/.bash_profile`) by adding the following line:
   ```bash
   source /path/to/ollama-completion.bash
   ```
3. Reload your shell configuration file to activate the completion:
   ```bash
   source ~/.bashrc  # or source ~/.bash_profile, depending on your setup
   ```

This will enable tab completion for `ollama run <model>` with dynamically listed models.


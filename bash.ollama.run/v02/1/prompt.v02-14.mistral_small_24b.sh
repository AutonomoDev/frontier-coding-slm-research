```bash
_ollama_run_completions() {
    local cur prev words cword
    _init_completion || return

    # Trigger condition: Only offer completions when the command is `ollama run`
    if [[ ${words[1]} != "run" ]]; then
        return
    fi

    # Capture the output of `ollama list` into a variable
    local models_output
    models_output=$(ollama list 2>/dev/null)

    # Check if `ollama list` failed (output is empty or null)
    if [[ -z "$models_output" ]]; then
        return
    fi

    # Split the output by whitespace and newlines into an array
    local IFS=$'\n'
    read -r -a models <<< "${models_output// /$'\n'}"
    unset IFS

    # Filter model names based on the current word being completed
    local prefix="${cur#${words[1]}}"
    local filtered_models=()

    for model in "${models[@]}"; do
        if [[ $model == "$prefix"* ]]; then
            filtered_models+=("$model")
        fi
    done

    # Sort the filtered models alphabetically
    IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
    unset IFS

    # Populate COMPREPLY with the sorted and filtered model names
    COMPREPLY=( "${sorted_models[@]}" )
}

complete -F _ollama_run_completions ollama
```

To install and activate this completion script:
1. Save the above script to a file, e.g., `~/.bash_completion.d/ollama`.
2. Add the following line to your `.bashrc` or equivalent shell configuration file:
   ```bash
   source ~/.bash_completion.d/ollama
   ```
3. Reload your shell configuration by running:
   ```bash
   source ~/.bashrc
   ```

This will enable dynamic model completion for `ollama run <model>` based on the output of `ollama list`.


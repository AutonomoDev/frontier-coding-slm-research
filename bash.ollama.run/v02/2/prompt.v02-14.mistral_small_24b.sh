```bash
_ollama_run_completions() {
    local cur prev words cword
    _init_completion || return

    # Check if the command is `ollama run` and we are completing after `run`
    if [[ ${words[1]} == "run" && $cword -gt 2 ]]; then
        # Capture the output of `ollama list` into a variable
        local models
        models=$(ollama list 2>/dev/null)

        # Check if `ollama list` was successful and has output
        if [[ -n $models ]]; then
            # Split the output by whitespace or newline to get individual model names
            IFS=$'\n' read -r -d '' -a model_array <<< "$(echo -e "${models// /$'\n'}")"

            # Get the current word being completed
            local cur="${COMP_WORDS[COMP_CWORD]}"

            # Filter model names by prefix and populate COMPREPLY
            local filtered_models=()
            for model in "${model_array[@]}"; do
                if [[ $model == "$cur"* ]]; then
                    filtered_models+=("$model")
                fi
            done

            # Sort the filtered models alphabetically
            IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
            unset IFS

            # Assign to COMPREPLY
            COMPREPLY=( "${sorted_models[@]}" )
        fi
    fi
}

complete -F _ollama_run_completions ollama

# Installation/activation instructions:
# Save this script to a file, e.g., `~/.bash_completion.d/ollama-completion`.
# Add the following line to your `.bashrc` or equivalent shell configuration file:
#   source ~/.bash_completion.d/ollama-completion
# Then reload your shell configuration:
#   source ~/.bashrc
```


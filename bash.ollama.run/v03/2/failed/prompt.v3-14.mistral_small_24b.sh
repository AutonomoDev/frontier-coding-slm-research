_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || return 1

    # Check if the previous word is 'run' and the command is 'ollama'
    if [[ ${words[0]} == "ollama" && ${prev} == "run" ]]; then
        local models
        models=$(ollama list)

        # Check if ollama list returned any output
        if [[ -z "$models" ]]; then
            return 1
        fi

        # Filter and sort the model names based on current word prefix
        local filtered_models=()
        for model in $models; do
            if [[ $model == "$cur"* ]]; then
                filtered_models+=("$model")
            fi
        done

        # Sort the filtered models alphabetically
        IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
        unset IFS

        # Populate COMPREPLY with the sorted model names
        COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
    fi
}

complete -F _ollama_run_completion ollama

# Installation instructions:
# Save this script to a file, e.g., ~/.bash_completions/ollama_completion.sh.
# Add the following line to your .bashrc or equivalent shell configuration file:
# source ~/.bash_completions/ollama_completion.sh
# Then reload your shell configuration with:
# source ~/.bashrc

# Save this script to a file, e.g., ~/.bash_completions/ollama_completion.sh.
# Add the following line to your .bashrc or equivalent shell configuration file:
# source ~/.bash_completions/ollama_completion.sh
# Then reload your shell configuration with:
# source ~/.bashrc


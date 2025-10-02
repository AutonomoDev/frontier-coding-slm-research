# [[HUMAN COMMENTED-OUT]]
#Here is a bash-completion function for `ollama run <model>`:

_ollama_run() {
    # Get the current word being completed (from COMP_WORDS/COMP_CWORD)
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # If we're not completing the model argument, exit early
    if [[ "$cur" != "run"* ]]; then
        return 0
    fi

    # Get a list of all models
    local models="$(ollama list)"

    # Filter the list to only include models that start with the current word
    local -a filtered_models=()
    while IFS=' ' read -r model; do
        [[ "$model" == "$cur"* ]] && filtered_models+=("$model")
    done <<< "$models"

    # If there are no matching models, exit early
    if ((${#filtered_models[@]} == 0)); then
        return 0
    fi

    # Sort the remaining models alphabetically
    filtered_models=($(sort -t ' ' <<< "${filtered_models[*]}"))

    # Populate COMPREPLY with the sorted list of matching models
    local -a compreply=()
    for model in "${filtered_models[@]}"; do
        compreply+=("$model")
    done

    # Assign the filtered and sorted list to COMPREPLY
    COMPREPLY=("${compreply[@]}")
}

# [[HUMAN COMMENTED-OUT]]
#To activate this completion function, you can add the following line to your `.bashrc` file:
#```bash
#complete -F _ollama_run ollama
#```
#This will tell Bash that when you press <Tab> after `ollama run`, it should use the `_ollama_run` function to provide completion suggestions.
#
#Note that this completion function assumes that you have a command called `ollama` in your PATH, and that it has a subcommand called `list` that returns a list of all available models when run with no arguments. If your setup is different, you may need to modify the function accordingly.


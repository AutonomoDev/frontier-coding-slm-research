_ollama_run_completion() {
    local cur prev words cword
    # Fallback for _get_comp_words_by_ref if it's missing or fails
    if declare -F _get_comp_words_by_ref > /dev/null; then
        _get_comp_words_by_ref -n : $1
    else
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Check if the previous word is 'run' and the command is 'ollama'
    if [[ $prev == run ]] && [[ ${words[0]} == ollama ]]; then
        local models
        # Capture the output of `ollama list` into a variable
        models=$(ollama list)

        # Check if `ollama list` returned any models
        if [[ -n $models ]]; then
            local filtered_models=()
            # Iterate over each model name and filter by prefix
            for model in $models; do
                if [[ $model == "$cur"* ]]; then
                    filtered_models+=("$model")
                fi
            done

            # Sort the filtered models alphabetically
            IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
            unset IFS

            # Populate COMPREPLY with the sorted model names
            COMPREPLY=( $(compgen -W "${sorted_models[@]}" -- "$cur") )
        fi
    fi
}

complete -F _ollama_run_completion ollama

# Installation instructions:
# Save this script to a file, e.g., `~/.bash_completions/ollama`.
# Add the following line to your `.bashrc` or equivalent shell configuration file:
# source ~/.bash_completions/ollama
# Then reload your shell configuration with:
# source ~/.bashrc

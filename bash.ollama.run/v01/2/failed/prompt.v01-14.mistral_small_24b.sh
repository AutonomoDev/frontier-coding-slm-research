_ollama_run_completion() {
    local cur prev words cword
    _init_completion || return

    # Get the current word and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the command is `ollama run` and we are at the second argument, complete model names
    if [[ ${prev} == "run" ]]; then
        local models
        # Attempt to get the list of models
        models=$(ollama list 2>/dev/null)

        # Check if ollama list succeeded
        if [[ $? -eq 0 && -n "$models" ]]; then
            # Split models by whitespace or newline and filter by current prefix
            IFS=$'\n' read -r -d '' -a model_array <<<"$models"
            COMPREPLY=( $(compgen -W "${model_array[@]}" -- "$cur") )
        fi
    fi

    return 0
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save the above script to a file, e.g., `ollama-completion.bash`.
# 2. Source the script in your shell configuration file (e.g., `.bashrc`, `.bash_profile`):
#    source /path/to/ollama-completion.bash
# 3. To activate it immediately without restarting the shell, run:
#    source /path/to/ollama-completion.bash
# 
# This will enable completion for `ollama run <model>` dynamically listing available models.

# Bash completion for 'ollama run' command to list available models dynamically.

_ollama_run() {
    local cur_word prev_word cmd_prefix models output

    # Check if we're completing the third word (after 'ollama run')
    if [[ ${COMP_CWORD} -eq 2 && "${COMP_WORDS[0]}" == "ollama" && "${COMP_WORDS[1]}" == "run" ]]; then
        cur_word="${COMP_WORDS[2]}"
        prev_word="${COMP_WORDS[1]}"

        # Get list of models by running 'ollama list' safely.
        if output=$(ollama list 2>/dev/null); then
            # Split the model names into an array (handles both newline and space-separated outputs)
            IFS=' 
' read -r -d '' -a models <<< "$output"

            # Filter models that start with 'cur_word', then sort them.
            COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur_word") )
        else
            # Gracefully handle errors in 'ollama list'.
            COMPREPLY=()
        fi

    fi
}

# Activate completion for 'ollama' command with the custom function.
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation/Activation Instructions:
# 1. Save the script to your shell configuration file (e.g., `~/.bashrc` or `/etc/bash_completion.d/ollama-completion.sh`).
# 2. Reload the configuration by running:  
#    #    source ~/.bashrc  # or source /etc/bash_completion.d/ollama-completion.sh
#    ```
# 3. Now, type `ollama run <Tab>` to see available models dynamically.

bash
# bash completion script for ollama run <model>
# This function provides completions for ollama run commands.

_ollama_run_complete() {
    # Only trigger for 'ollama' commands
    if [[ ${COMP_WORDS[0]} != "ollama" ]]; then
        return
    fi

    # Check if the command is 'ollama run'
    local cmd=${COMP_WORDS[1]}
    if [[ $cmd != "run" ]]; then
        return
    fi

    # Get available models from ollama list, handle error silently
    local models=()
    {
        ollama list 2>/dev/null | while read -r line; do
            models+=("$line")
        done
    } || {
        # If ollama command fails, return no completions
        return
    }

    # Filter models based on current word prefix
    local current=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ $model == "$current"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    # Sort the completions alphabetically
    if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
        COMPREPLY=( $(printf '%s\n' "${COMPREPLY[@]}" | sort) )
    fi
}

# Install by adding to bash completion path:
#   /etc/profile.d/bash_completion.sh or ~/.bashrc
# Source the script after adding:
#   source /etc/bash_completion.d/ollama_run.sh

# For immediate activation, add this line to your .bashrc and source it:
complete -F _ollama_run_complete ollama

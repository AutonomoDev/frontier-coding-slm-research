# Bash completion function for 'ollama run <model>'
_ollama_completion() {
    # Ensure _get_comp_words_by_ref is available, fallback to manual parsing if not
    if ! type _get_comp_words_by_ref &>/dev/null; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    else
        _get_comp_words_by_ref -n : cur prev
    fi

    # Ensure we are completing after 'ollama run'
    if [[ "${COMP_CWORD}" -eq 2 && "${prev}" == "run" ]]; then
        # Fetch the list of models from ollama
        local model_list
        if ! model_list=$(ollama list 2>/dev/null); then
            return
        fi

        # Split the output into an array, preserving whitespace
        IFS=$'\n' read -r -d '' -a models <<< "$model_list"

        # Filter and sort matching models
        local filtered_models=()
        for model in "${models[@]}"; do
            [[ $model == "$cur"* ]] && filtered_models+=("$model")
        done

        if (( ${#filtered_models[@]} > 0 )); then
            COMPREPLY=( $(compgen -W "$(printf "%s\n" "${filtered_models[@]}" | sort)" -- "$cur") )
        fi
    fi
}

# Attach the completion function to 'ollama'
complete -F _ollama_completion ollama

# Installation instructions:
# 1. Save this script as /etc/bash_completion.d/ollama.sh or ~/.local/share/bash-completion/completions/ollama.
# 2. Ensure bash completion is enabled by adding `[[ $- == *i* ]] && source /usr/share/bash-completion/bash_completion` to your .bashrc if not already present.
# 3. Source the file in your shell: `source /etc/bash_completion.d/ollama.sh` or `source ~/.local/share/bash-completion/completions/ollama`.
# 4. Restart your terminal session or run `source ~/.bashrc`.

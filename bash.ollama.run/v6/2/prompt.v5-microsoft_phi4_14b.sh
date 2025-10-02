# Bash completion script for `ollama run` command using `bash-completion` framework

_ollama_run_completion() {
    # Ensure we are completing the 'run' subcommand under 'ollama'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Fallback if '_get_comp_words_by_ref' is not available
    if [[ $? != 0 ]]; then
        cword=$((COMP_CWORD-1))
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[cword]}"
        words=("${COMP_WORDS[@]}")
    fi

    # Ensure the current command structure is 'ollama run <current_word>'
    if [[ ${#words[@]} -le cword || "$prev" != "run" || "${words[0]}" != "ollama" ]]; then
        return 1
    fi

    # Capture and parse the output of `ollama list`
    local model_list=()
    local models_output
    models_output=$(ollama list 2>/dev/null) || return 1
    
    # Extract model names, skipping header line
    while IFS=$'\t' read -r name _; do
        [[ "$name" == NAME* ]] && continue  # Skip the header
        model_list+=("$name")
    done <<< "$(echo "$models_output" | sed 's/ *\([^ ][^ ]*\) */\1\t/g')"

    # Filter models based on current input
    COMPREPLY=()
    for model in "${model_list[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    # Remove duplicates by converting the array to a set and back
    declare -A unique_models
    for item in "${COMPREPLY[@]}"; do
        unique_models["$item"]=1
    done
    COMPREPLY=("${!unique_models[@]}")

    # Sort suggestions alphabetically
    COMPREPLY=( $(compgen -W "$(printf "%s\n" "${COMPREPLY[@]}" | sort)" -- "$cur") )
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama


# [[HUMAN COMMENTED-OUT]]
#This script provides a Bash completion handler for the `ollama run` command, ensuring that suggestions are based on local model names obtained from `ollama list`. It respects all specified requirements and handles potential issues such as missing `_get_comp_words_by_ref` gracefully.


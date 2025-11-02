# Analysis: No dangerous code detected. The script only reads output from `ollama list` and performs bash completion. No superuser operations, file writes, or malicious activity found.

#!/bin/bash
# Bash-completion for "ollama run <model>"
# This function dynamically lists available models by parsing the output of "ollama list."
# It only triggers completions when completing after the word "run".

ollama_run_completion() {
    # Get the current word (what's being typed) and its previous word.
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only offer completions if the previous argument is "run"
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Retrieve the list of models from "ollama list".
    local output models_arr match_models sorted_models model i temp inserted
    output=$(ollama list 2>/dev/null)
    
    # If "ollama list" fails or returns nothing, exit gracefully.
    if [ -z "$output" ]; then
        return 0
    fi

    # Populate an array with each model name (models are expected to be whitespace‐separated).
    models_arr=()
    for model in $output; do
        models_arr+=("$model")
    done
    
    # Get the current prefix being completed.
    local prefix="${COMP_WORDS[2]}"

    # Filter out only those model names starting with the given prefix.
    match_models=()
    for model in "${models_arr[@]}"; do
        if [[ "$model" == ${prefix}* ]]; then
            match_models+=("$model")
        fi
    done

    # Sort the matched models alphabetically using a simple insertion sort (only built-in Bash commands).
    sorted_models=()
    for model in "${match_models[@]}"; do
        inserted=false
        for ((i = 0; i < ${#sorted_models[@]}; i++)); do
            if [[ "$model" < "${sorted_models[i]}" ]]; then
                # Insert "model" before the current element.
                sorted_models=( "${sorted_models[@]:0:i}" "$model" "${sorted_models[@]:i}" )
                inserted=true
                break
            fi
        done
        if [ "$inserted" = false ]; then
            sorted_models+=("$model")
        fi
    done

    # Use compgen to generate completions from the sorted list.
    COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
}

# Register the completion function for the "ollama" command.
complete -F ollama_run_completion ollama

# Installation/Activation:
# 1. Save this script to a file (e.g., /etc/bash_completion.d/ollama-run.bash).
# 2. Source it in your shell or add "source /path/to/script" to your ~/.bashrc.
# 3. Reload your bash configuration (for example, run: source ~/.bashrc).
bash
# Bash completion script for 'ollama run <model>'
_ollama_run_complete() {
    # Only complete if the command is 'ollama run' and we are completing the model argument
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

echo "Broken; runs in an infinite loop"
exit 1
    # Check if the current completion is for the second positional parameter of 'ollama run'
    [[ "${#words[@]}" -ne 2 || "$prev" != "run" ]] && return

    # Capture output of `ollama list` into a variable
    local model_list
    model_list=$(ollama list 2>/dev/null)

    # Check if ollama list was successful and non-empty
    if [[ $? -ne 0 || -z "$model_list" ]]; then
        return
    fi

    # Split the output into an array, filter by prefix, sort alphabetically, and set COMPREPLY
    local models=()
    while IFS= read -r model; do
        models+=("$model")
    done <<<"$model_list"

    # Filter models starting with 'cur' (current word being completed)
    local filtered_models=("${models[@]/#/$cur}")
    filtered_models=("${filtered_models[@]#$cur}")

    # Sort and prepare completions using compgen, which is better for handling empty prefixes
    COMPREPLY=($(compgen -W "$(printf '%s\n' "${filtered_models[@]}" | sort)" -- "$cur"))
}

# Associate completion function with 'ollama run'
complete -F _ollama_run_complete ollama

# Installation instructions:
# 1. Save this script to a file, e.g., ~/.bash_completion.d/ollama.bash
# 2. Add the following line to your .bashrc if not already present: source ~/.bash_completion.d/ollama.bash
# 3. Reload shell configuration with `source ~/.bashrc` or restart terminal.

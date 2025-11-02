```bash
# Bash completion script for 'ollama run <model>'
_ollama_run_completion() {
    # Check if we are in the right context
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Only complete after 'ollama run' when there's a word to complete (after `run`)
    if [[ ${#words[@]} -ne 2 || "${words[1]}" != "run" || "$cword" -lt 3 ]]; then
        return
    fi

    # Capture the output of ollama list into a variable.
    # If this fails, do nothing (silent failure)
    local models_output=$(ollama list 2>/dev/null) || return

    # Split the captured output into an array
    mapfile -t model_list <<< "$models_output"

    # Get the current word being completed
    local prefix="${cur}"

    # Filter and sort models by matching prefix, using manual filtering
    local suggestions=()
    for model in "${model_list[@]}"; do
        if [[ "$model" == "$prefix"* ]]; then
            suggestions+=("$model")
        fi
    done

    # Sort alphabetically
    IFS=$'\n' sorted_suggestions=($(sort <<<"${suggestions[*]}")); unset IFS

    # Populate COMPREPLY array for bash to use the completion list
    COMPREPLY=( "${sorted_suggestions[@]}" )
}

# Registering the function with 'ollama run'
complete -F _ollama_run_completion ollama

# Installation Instructions:
# 1. Save this script into a file, e.g., `~/.bash_completion.d/ollama.bash`.
# 2. Ensure your shell loads the bash-completion scripts by adding (if not already present):
#    if [ -d ~/.bash_completion.d ]; then
#        for i in ~/.bash_completion.d/*.bash; do
#            source "$i"
#        done
#    fi
#   to your `.bashrc`.
# 3. Reload the shell session or run `source ~/.bashrc` to activate completions.
```


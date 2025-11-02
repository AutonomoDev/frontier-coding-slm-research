```bash
# Bash completion script for 'ollama run <model>'

_ollama_run_completion() {
    local cur prev words cword model_list models filtered_models
    
    # Get the current word being completed and its position
    _get_comp_words_by_ref -n : cur prev words cword

    # Trigger condition: We only want to provide completions for 'ollama run <model>'
    if [[ "${#words[@]}" -ne 3 || "$prev" != "run" ]]; then
        return
    fi
    
    # Capture the output of 'ollama list' into a variable, safely handling any errors by redirecting stderr
    model_list=$(ollama list 2>/dev/null)
    
    # If ollama list failed or produced no output, exit gracefully with no completions
    if [[ -z "$model_list" ]]; then
        return
    fi
    
    # Split the model names into an array
    IFS=$'\n' read -rd '' -a models <<<"$model_list"
    
    # Filter models that match the current word being completed (case insensitive)
    filtered_models=()
    for model in "${models[@]}"; do
        if [[ "$model" == ${cur}* ]]; then
            filtered_models+=("$model")
        fi
    done
    
    # Sort the matched models alphabetically
    IFS=$'\n' sorted_filtered_models=($(sort <<<"${filtered_models[*]}"))
    
    # Populate COMPREPLY with the sorted, filtered model names
    COMPREPLY=( "${sorted_filtered_models[@]}" )
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama

# Installation/activation instructions:
#
# 1. Save this script to a file named `ollama-completion.bash` in your home directory.
# 2. Add the following lines to your ~/.bashrc or ~/.bash_profile:
#    source ~/ollama-completion.bash
# 3. Reload your shell configuration by running: source ~/.bashrc or exec bash
```

### Instructions:

1. Save the script to a file named `ollama-completion.bash` in your home directory.
2. Add the following lines to your `~/.bashrc` or `~/.bash_profile`:
   ```bash
   source ~/ollama-completion.bash
   ```
3. Reload your shell configuration by running: `source ~/.bashrc` or `exec bash`.


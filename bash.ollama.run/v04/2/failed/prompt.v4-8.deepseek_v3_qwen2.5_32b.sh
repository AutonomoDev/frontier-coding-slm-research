# Bash completion for ollama's 'run' command

_ollama_run() {
    # Check if the current word is after 'run'
    local word="${COMP_WORDS[1]}"
    if [[ "$word" != "run" ]]; then
        return 1
    fi

    # Get the list of models from ollama list, skip header and extract first column (model names)
    local IFS=$'\n'   # Split on newlines only to preserve spaces in model names
    local models=($(ollama list | awk 'NR>1 {print $1}'))
    
    # Remove duplicates while preserving order
    local unique_models=()
    declare -A seen
    for m in "${models[@]}"; do
        [[ -z "$m" ]] && continue  # Skip empty lines (unlikely but just in case)
        if [[ -z ${seen[$m]} ]]; then
            seen["$m"]=1
            unique_models+=("$m")
        fi
    done

    # Generate completions matching the current word fragment
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${unique_models[*]}" -- "$cur") )
}

# Register completion for 'ollama run'
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
## To enable this, source the script or add it to your .bashrc
#```
#
#**Notes:**
#- The function `_ollama_run` is triggered when `ollama` is being completed.
#- It checks if the second word (`${COMP_WORDS[1]}`) is `run`.
#- Uses `awk 'NR>1 {print $1}'` to extract model names, skipping the header line.
#- Filters duplicates while preserving order using an associative array for seen models.
#- Uses `compgen -W ... -- "$cur"` to generate filtered completions based on the current word fragment.
#

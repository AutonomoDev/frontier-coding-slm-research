# Bash completion for ollama run <model>

_ollama_run() {
    # Activate only when completing the model argument after typing `ollama run`
    if [[ "${COMP_WORDS[COMP_CWORD-1]}" != "run" ]] || [[ "${COMP_WORDS[COMP_CWORD]}" = * ]]; then
        return
    fi

    # Run `ollama list` exactly once and capture its full output into a variable
    local models=$(ollama list 2>/dev/null)

    # If `ollama list` fails or returns empty, return without error and provide no completions
    if [[ -z "$models" ]]; then
        return
    fi

    # Use the current word being completed as the prefix and include only model names that start with that prefix
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    local models=$(echo "$models" | grep "^$cur")

    # If there are multiple matching models, sort them alphabetically before assigning to COMPREPLY
    local -a sorted_models=($(echo "$models" | sort))

    # Populate COMPREPLY manually from filtered & sorted results or use `compgen -W ... -- "$cur"` on a prepared, alphabetically sorted list
    COMPREPLY=()
    for model in "${sorted_models[@]}"; do
        COMPREPLY+=("$model")
    done
}

# Wire the function to `ollama` so that typing `ollama run <Tab>` triggers it
complete -F _ollama_run ollama

# Installation instructions:
# Save or source this script in your Bash completion directory (e.g., /etc/bash_completion.d) and then add the following line to your .bashrc:
#   if [[ -f /path/to/this/script ]]; then
#       source /path/to/this/script
#   fi
# Reload your .bashrc for the changes to take effect.



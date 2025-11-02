```bash
# Bash completion for 'ollama'
# This script depends only on built-in bash features and
# should be sourced from your .bashrc file after installation.

_ollama_list() {
    # Save the output of `ollama list` in a variable.
    local list_output
    if ! list_output="$(ollama list 2>/dev/null)"; then
        # If `ollama list` fails, silently return with no completions.
        return
    fi

    # Iterate over lines of $list_output and add each line to the
    # 'models' array. This is a safe way to store command output
    # in an array without using a while read loop.
    local models=()
    while IFS= read -r line; do
        models+=("$line")
    done <<< "$list_output"

    # Filter the model names based on the current word being completed
    # and populate COMPREPLY with the matches.
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Sort the completions and return them.
    _completion_sort_by_directories "${COMPREPLY[@]}"
}

# Complete 'ollama run' command with dynamic model list.
complete -F _ollama_list ollama

# Installation/activation instructions:
# ---------------------------------------
# 1. Save this script as 'ollama-completion.bash' in your home directory.
# 2. Add the following line to your .bashrc file:
#      source ~/ollama-completion.bash
# 3. Reload your .bashrc file with '. ~/.bashrc'.
```


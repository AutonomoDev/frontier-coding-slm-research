# Bash completion for 'ollama run' command
# Based on https://github.com/scop/bash-completion

_ollama_run() {
    local cur prev opts
    COMPREPLY=()

    # Get the current word (as a Bash array) and its previous one
    _get_comp_words_by_ref -n : cur prev

    # Check if we are completing for 'ollama run' command
    if [[ $prev != "run" ]]; then
        return 0
    fi

    # Get the list of available local models (excluding header)
    opts=$(ollama list --quiet --no-trunc | tail -n+2)

    # Filter out model names based on current word ($cur) and generate completions
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )

    return 0
}

# Register completion function for 'ollama' command
complete -F _ollama_run ollama

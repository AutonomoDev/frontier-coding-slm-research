# Function to list available models for `ollama run`
_ollama_run() {
    local cur prev opts

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the current word is not empty and the previous word is `run`
    if [[ ${cur} == "" && ${prev} == "run" ]]; then
        # Capture the output of `ollama list` and extract model names
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | tr -d ':')
        if [[ $? -ne 0 ]]; then
            return 1
        fi

        # Split the output into an array and complete from it
        COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
    else
        # Default completion for other cases
        COMPREPLY=($(compgen -W "run" -- ${cur}))
    fi

    return 0
}

# Register the completion function
complete -F _ollama_run ollama

# Installation snippet to add to .bashrc or .bash_profile
# echo 'source /path/to/this/script' >> ~/.bashrc

# [[HUMAN COMMENTED-OUT]]
# This script defines a bash-completion function `_ollama_run` for the `ollama run <model>` command. It dynamically lists available models by parsing the output of `ollama list`, extracting model names, and providing them as completion options. The script handles errors gracefully and adheres to Bash completion conventions.

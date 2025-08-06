# Script for completing the "ollama run" command
# Assumes ollama list produces a newline-separated list of model names

_ollama() {
    # Check if we're in the middle of completing a word
    if [[ "${COMP_WORDS[COMP_CWORD]}" != "" ]]; then
        return 0
    fi

    # Run "ollama list" and store output in variable
    local models
    if ! models=$(ollama list 2>/dev/null); then
        # Handle failure case
        return 1
    fi

    # Build a sorted list of model names that start with the current prefix
    local cur=${COMP_WORDS[COMP_CWORD]}
    local -a matches=()
    while IFS= read -r model; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done <<<"$models"
    if ((${#matches[@]} > 0)); then
        COMPREPLY=( "${matches[@]}" )
    fi
}

# Attach the completion function to "ollama"
complete -F _ollama ollama

# Installation: 1. Save the script in a file with a ".bash" extension, such as "/etc/bash_completion.d/ollama". 2. Source the file from your ".bashrc" file, such as by adding the line "source /etc/bash_completion.d/ollama". 3. Reload your ".bashrc" file with "source ~/.bashrc" or open a new terminal window.

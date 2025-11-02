#!/bin/bash
# Bash completion for "ollama run <model>"
_ollama_run() {
    # Ensure that there are at least three words: "ollama", "run", and the model name.
    if [[ ${COMP_CWORD} -lt 3 ]]; then
        return
    fi

    # Check if we're completing the "ollama run" subcommand.
    if [[ "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[2]}" != "run" ]]; then
        return
    fi

    # Get the current token to complete.
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Capture the output of 'ollama list', ignoring errors. If the command fails, no completions are offered.
    local lines=()
    if ! readarray -t lines < <(ollama list 2>/dev/null); then
        return
    fi

    # Process each line; split by whitespace to support models output on one or multiple lines.
    local suggestions=()
    for line in "${lines[@]}"; do
        for model in $line; do
            if [[ -n "$model" && "$model" == $cur* ]]; then
                suggestions+=("$model")
            fi
        done
    done

    COMPREPLY=( "${suggestions[@]}" )
}
complete -F _ollama_run ollama

# Installation Instructions:
# 1. Save this script to a file (e.g., /etc/bash_completion.d/ollama-run.bash).
# 2. Ensure the file is executable if required.
# 3. Source the completions in your shell configuration (for example, add "source /etc/bash_completion.d/ollama-run.bash" to ~/.bashrc).

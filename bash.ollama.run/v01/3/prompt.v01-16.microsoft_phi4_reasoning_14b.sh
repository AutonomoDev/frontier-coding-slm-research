#!/bin/bash
#
# ollama-run completion function for bash.
# This function completes model names only when the command is "ollama run".
#

_ollama_run_completion() {
    # Only complete if the second argument (subcommand) is exactly "run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Get the current word being completed.
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Retrieve model names from the output of "ollama list".
    # We assume that ollama list prints one model per line (or separated by whitespace).
    local IFS=$'\n'
    local models=()
    while read -r model; do
        # Skip any blank lines.
        [[ "$model" =~ ^[[:space:]]*$ ]] && continue
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    # If no models were found, do not offer completions.
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Use compgen to generate a list of possible completions matching the current word.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

# Register _ollama_run_completion for the "ollama run" command.
complete -F _ollama_run_completion ollama

# INSTALLATION INSTRUCTIONS:
#
# 1. Save this script to a file (for example, ollama-completion.sh).
#
# 2. To have the completion function loaded automatically in bash,
#    place it into one of your bash_completion directories.
#
#    On many systems you can save it as:
#      /etc/bash_completion.d/ollama-completion.sh
#
#    Then restart your shell or source the file directly to test it:
#      source /etc/bash_completion.d/ollama-completion.sh
#
# 3. Alternatively, if your system does not use bash_completion,
#    add the following line to your ~/.bashrc:
#      source /path/to/ollama-completion.sh
#
# Now, when you type "ollama run" followed by a space and press Tab,
# the available model names will be suggested.

#!/bin/bash

# Define a bash completion function for `ollama run`
_ollama_run_completion() {
    # Get current word index, words, and cursor position in the command line buffer
    local cur prev words cword
    _init_completion -n : || return

    # Function to handle failure gracefully: suppress error messages from 'ollama list'
    ollama_list_models() {
        if ! output=$(ollama list 2>/dev/null); then
            return 1
        fi
        echo "$output" | awk 'NR>3 {print $1}' | sed -e 's/://'
    }

    # If we are completing the first argument after `ollama run`
    if [[ $cword -eq 2 ]]; then
        COMPREPLY=($(compgen -W "$(ollama_list_models)" -- "$cur"))
    fi

    return 0
}

# Install the completion function for 'ollama'
complete -F _ollama_run_completion ollama

# Instructions to install this script:
# Save this script as `ollama-completion.bash` and source it in your shell configuration file.
#
# Example: Add the following line to ~/.bashrc or ~/.bash_profile
# if [ -f /path/to/ollama-completion.bash ]; then
#     . /path/to/ollama-completion.bash
# fi

# Reload bash configuration:
# source ~/.bashrc  # or source ~/.bash_profile, depending on where you added the line.

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# [[HUMAN COMMENTED-OUT]]
# - **Completion Function**: `_ollama_run_completion` is defined to handle autocompletion for `ollama run`.
# [[HUMAN COMMENTED-OUT]]
#   
# [[HUMAN COMMENTED-OUT]]
# - **Initialization**: Uses `_init_completion` to initialize completion context variables (`cur`, `prev`, `words`, and `cword`).
# [[HUMAN COMMENTED-OUT]]
# - **Error Handling**: The function `ollama_list_models` captures the output of `ollama list` safely, suppressing errors with `2>/dev/null`.
# [[HUMAN COMMENTED-OUT]]
# - **Parsing Output**: 
# [[HUMAN COMMENTED-OUT]]
#   - Uses `awk 'NR>3 {print $1}'` to skip header lines and extract model names (first column).
# [[HUMAN COMMENTED-OUT]]
#   - Applies `sed -e 's/://'` to remove the colon from model names.
# [[HUMAN COMMENTED-OUT]]
# - **Completion Logic**: If the user is at the position of specifying a model (`cword -eq 2`), it generates completion suggestions using `compgen`.
# [[HUMAN COMMENTED-OUT]]
# - **Installation Instructions**:
# [[HUMAN COMMENTED-OUT]]
#   - Save and source this script in your shell configuration file (e.g., `.bashrc` or `.bash_profile`).
# [[HUMAN COMMENTED-OUT]]
#   - Source the configuration file to apply changes.
# [[HUMAN COMMENTED-OUT]]
# This script is designed to be portable, leveraging only built-in bash tools (`awk`, `sed`) for processing.

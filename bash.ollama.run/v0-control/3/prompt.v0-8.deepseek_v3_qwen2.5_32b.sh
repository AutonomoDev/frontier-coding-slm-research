#!/bin/bash

# Complete 'ollama run' command by listing available models from `ollama list` output.

_ollama_run() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If the previous word is 'run', suggest model names.
    if [[ ${prev} == "run" ]]; then
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | tr -d ':')
        COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
    fi

    return 0
}

# Ensure the completion function is registered for the 'run' subcommand.
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 1. **_ollama_run Function**:
#    - This function handles completion when `ollama` is followed by `run`.
#    - It fetches model names from the output of `ollama list`, skipping the header line.
#    - Uses `awk` to extract the first column (model names), removes any trailing colon, and generates completions dynamically.
# 
# 2. **Completion Registration**:
#    - Registers `_ollama_run` as the completion function for `ollama run`.
# 
# ### Installation Instructions:
# Save the script in a file like `ollama-completion.bash`, then source it or add to your shell profile (e.g., `.bashrc`):
# source /path/to/ollama-completion.bash
# 
# This setup ensures that when you type `ollama run <TAB>`, available models are listed based on the current output of `ollama list`. The approach is self-contained and handles errors by suppressing them (`2>/dev/null`).

#!/usr/bin/env bash

_ollama_run() {
    local cur prev words cword comps opts model_list old_wb
    COMPREPLY=()

    # Get the current word and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "$prev" == "ollama" && "$COMP_CWORD" -eq 2 ]]; then
        # List available models
        model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
        
        # Handle colon in word breaks to allow for partial matches on model names
        old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

        COMPREPLY=($(compgen -W "$model_list" -- "$cur"))
        
        # Restore original word breaks
        COMP_WORDBREAKS="$old_wb"
    else
        # If not in the correct position, do nothing
        return 0
    fi
}

# Register the completion function with bash-completion framework
complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Function Definition**: The `_ollama_run` function is defined to handle the completion logic for the `ollama run` command.
#2. **Variable Initialization**: Variables are initialized to store current word (`cur`), previous word (`prev`), and model list (`model_list`).
#3. **Model List Retrieval**: The script retrieves available models using `ollama list`, processes them to remove duplicates, and stores them in `model_list`.
#4. **Colon Handling**: The script temporarily removes colons from the word breaks to allow for partial matches on model names containing colons.
#5. **Completion Logic**: Using `compgen -W` with the available models, it generates possible completions based on the current input (`cur`).
#6. **Restoration**: The original word breaks are restored after generating completions.
#7. **Bash Completion Registration**: The script registers the completion function with the bash-completion framework using `complete -F _ollama_run ollama`.
#
#This script ensures robust handling of model names containing colons and adheres to the specified requirements.


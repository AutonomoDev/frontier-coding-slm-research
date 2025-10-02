#!/bin/bash

_ollama_run() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev # Get the current word and previous one

    if [[ ${COMP_WORDS[0]} != "ollama" || ${prev} != "run" ]]; then 
        return
    fi
  
    local models=$(ollama list | tail -n +2 | cut -d ' ' -f 1) # Get the model names (skip header line)
    COMPREPLY=( $(compgen -W "${models}" -- "$cur") ) # Generate completion suggestions
}

# Check if _get_comp_words_by_ref is available. If not, fall back to manually setting cur and prev
if declare -F _get_comp_words_by_ref >/dev/null 2>&1; then
    complete -F _ollama_run ollama
else
    complete -o nospace -C 'ollama run' ollama
fi

#
#This script first checks if the current word being completed is `run`, and if it's not, it returns without doing anything. If the current word is `run`, it extracts all model names from the output of `ollama list` using `cut`. Then it uses Bash's `compgen` to generate completion suggestions based on these model names, and `complete -F` to register this function as a completion handler for the `ollama run` command.
#
#In case `_get_comp_words_by_ref` is not available, we fall back to using `-C 'ollama run'` option to manually provide the command string that will be used for generating completions. This assumes that the Ollama CLI can handle this mode of completion without any issues and that the output of `ollama list` is correctly formatted (i.e., model names are not truncated or contain special characters).
#
#Remember to replace 'ollama' with your actual command name if it differs. This script assumes that 'ollama' is in PATH and the user has sufficient permissions to run it. If that's not the case, you might need more complex handling.


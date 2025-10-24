#!/bin/bash
# This is a bash completion script for 'ollama run' command using bash-completion v2 framework.
_ollama_run() {
    local cur prev words cword
    _get_comp_words_by_ref -n :=: cur prev words cword

    # Targeted Triggering: Activate the completion logic only for 'ollama run' command.
    if [[ ${prev} == "run" && ${COMP_WORDS[0]} == "ollama" ]]; then
        COMPREPLY=( $(compgen -W "$(ollama list | tail -n +2 | awk '{print $1}' | sort | uniq)" -- ${cur}) )
    else
        # If the word being completed does not match any available model, provide no suggestions.
        COMPREPLY=()
    fi
}

# Register the completion function for 'ollama run'.
complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#In this script:
#1. The `_get_comp_words_by_ref` command is used to set variables like `cur` (current word), `prev` (previous word), and others. If it's not available, the script manually sets these variables from `COMP_*`.
#2. For the `run` subcommand of `ollama`, it generates a list of unique model names from the output of 'ollama list', removes the header line with 'tail -n +2', extracts only the first column (model name) with 'awk', and sorts the result in alphabetical order.
#3. The generated list is used as source for auto-completion suggestions by `compgen`, which filters out model names based on what user has typed so far (${cur}).


# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for the `ollama run` command as described in your specifications:

#/usr/bin/env bash

_ollama_run() {
    local cur prev words cword

    # Extract the current word, previous word and all words before it.
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if the completion is for 'ollama run' command
    if [[ ${words[1]} == "run" ]]; then
        local models
        # Get the list of models by parsing the output of `ollama list`.
        models=$(ollama list | awk 'NR>1{print $1}')

        # Filter out models that don't match what user has typed so far.
        COMPREPLY=($(compgen -W "$models" -- ${cur}))
    fi

    return 0
}

# Register the function to provide completions for 'ollama run'.
complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#This script will:
#1. Activate only when the second word in the command line is `run`.
#2. Run `ollama list`, parse the output and extract model names using `awk`.
#3. Filter out models that don't match what user has typed so far with `compgen -W`.
#4. Populate `COMPREPLY` array with filtered suggestions.


#!/bin/bash

# Define a function to parse the output of `ollama list` and extract model names
_get_model_names() {
    # Call `ollama list` and pipe the output to `awk '{print $1}'`
    # This will extract only the first column, which contains the model names
    ollama list | awk '{print $1}'
}

# Define a function to perform the actual completion
_ollama_run() {
    # Check if the second word in the command line is `run`
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Get the currently typed word (without the 'ollama' and 'run' words)
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Filter the model names based on the current word
    COMPREPLY=($(compgen -W "$(_get_model_names)" -- "${cur}"))
}

# Register the function as a completion handler for `ollama run`
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
#Note: This script uses the `complete` built-in command to register `_ollama_run` as a completion handler for `ollama run`. The `-F` option specifies that the function should be called with the current word (`COMP_WORDS[COMP_CWORD]`) and the completion prefix (i.e., the text before the cursor) as arguments.
#
#The `_get_model_names` function uses `awk '{print $1}'` to extract the first column from the output of `ollama list`, which contains the model names. The `compgen -W` command is used to generate a list of completion suggestions based on the current word and the model names extracted by `_get_model_names`.
#
#The rest of the script consists of standard Bash code to check if the second word in the command line is `run`, and to set up the completion prefix and function arguments.


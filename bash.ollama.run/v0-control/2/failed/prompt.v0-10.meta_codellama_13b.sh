#!/bin/bash

_ollama_models() {
    local models
    if ! IFS=$'\n' read -r -d '' -a models < <(ollama list --format="%{name}"); then
        # If the command fails, we return an empty string to indicate there are no completions
        return 0
    fi
    COMPREPLY=( "${models[@]}" )
}

complete -F _ollama_models ollama run

# [[HUMAN COMMENTED-OUT]]
# This script defines a function called `_ollama_models` that runs the `ollama list` command and parses its output to extract the names of the available models. The function uses the `read` builtin with the `-r` option to read the output of `ollama list` into an array, where each element is a line in the output.
# [[HUMAN COMMENTED-OUT]]
# 
# [[HUMAN COMMENTED-OUT]]
# The function then sets the `COMPREPLY` variable to this array, which tells the shell that there are completions available for the `ollama run` command. The `-F` option to the `complete` command specifies that we want to use a function as the source of completions for the `ollama run` command.
# [[HUMAN COMMENTED-OUT]]
# 
# [[HUMAN COMMENTED-OUT]]
# This snippet uses the `eval` builtin to evaluate the output of the `_ollama_models` function as a Bash script. The `__EOF__` marker is used to indicate the end of the input, and the `< /dev/stdin` redirection specifies that the input should come from standard input.
# [[HUMAN COMMENTED-OUT]]
# 
# [[HUMAN COMMENTED-OUT]]
# The `eval` builtin evaluates the output of the `_ollama_models` function as a Bash script, which defines the `_ollama_models` function and sets up completion for the `ollama run` command using it.
#!/bin/bash
# This is a bash completion function for the command `ollama run <model>`
# that dynamically lists available models by parsing the output of `ollama list`

_ollama_run() {
  # Get the list of models from `ollama list`
  local models=$(ollama list | awk '{print $1}')
  
  # Build an array of models for bash completion
  COMPREPLY=($(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Install the bash completion function
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# This script defines a bash completion function called `_ollama_run` that is triggered when the command `ollama run <model>` is typed in the shell. The function first gets the list of models from `ollama list` using awk to extract the first column (the model name). It then builds an array of models for bash completion using `compgen -W` and completes the user input with the `--` option, which tells Bash to complete as much of the word as possible.
# [[HUMAN COMMENTED-OUT]]
# 
# [[HUMAN COMMENTED-OUT]]
# Finally, the script installs the `_ollama_run` function as a completion function for the `ollama run <model>` command using the `complete` builtin.

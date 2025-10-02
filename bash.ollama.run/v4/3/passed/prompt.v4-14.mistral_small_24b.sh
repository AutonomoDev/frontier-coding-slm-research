#!/bin/bash

# Function to provide completions for `ollama run` command
_ollama_run_completion() {
  local cur prev words cword
  _init_completion || return

  # Check if the second word is exactly 'run'
  if [[ ${COMP_WORDS[1]} != "run" ]]; then
    return
  fi

  # Get the current word being completed
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Parse the output of `ollama list` to get model names
  local models
  models=$(ollama list | awk 'NR>1 {print $1}')

  # Filter the model names based on the current word
  COMPREPLY=($(compgen -W "${models}" -- ${cur}))

  return 0
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completion` that is triggered when completing the `run` subcommand of `ollama`. It parses the output of `ollama list`, extracts model names, and filters them based on the current word being typed. The filtered suggestions are then provided as completions.


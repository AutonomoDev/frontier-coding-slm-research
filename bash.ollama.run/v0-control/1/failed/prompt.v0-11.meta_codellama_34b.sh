#!/bin/bash

## @param $1 string command name
## @param $2 string command argument
_ollama_run() {
  # Retrieve models list using `ollama list` command
  local models="$(ollama list)"

  # Parse the output and extract the model names
  local IFS=$'\n'
  local models=($models)

  # Generate completion options for each model name
  COMPREPLY=()
  for model in "${models[@]}"; do
    COMPREPLY+=("${model%%:*}")
  done
}

## Installation snippet
complete -F _ollama_run ollama run
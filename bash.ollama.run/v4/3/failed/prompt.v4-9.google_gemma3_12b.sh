#!/bin/bash

# ollama run completion script

# Function to get the list of available models
_ollama_run_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local models

  # Get the list of models from ollama list
  models=$(ollama list | tail -n +2 | awk '{print $1}')

  COMPREPLY=()
  local word
  for word in $models; do
    if [[ "$word" == *"$cur"* ]]; then
      COMPREPLY+=("$word")
    fi
  done

  # Remove duplicate suggestions (important for robustness)
  COMPREPLY=($(echo "${COMPREPLY[*]}" | sort -u))
}

# Check if the user is trying to complete the model name after "ollama run"
if [[ "${COMP_WORDS[1]}" == "run" ]]; then
  _ollama_run_completions
fi


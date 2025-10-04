#!/bin/bash

# Bash completion for `ollama run <model>`

_ollama_run_completion() {
  local models
  # Use ollama list to get available models.  Suppress errors in case ollama isn't installed.
  models=$(ollama list 2>/dev/null | awk '{print $1}')

  COMPREPLY=()
  for model in $models; do
    COMPREPLY+=("$model")
  done
}

complete -F _ollama_run_completion ollama run

# Installation:
# 1. Save this script to a file, e.g., ~/.bash_completion.d/ollama-run-completion.bash
# 2. Source the file in your .bashrc or .bash_profile:
#    source ~/.bash_completion.d/ollama-run-completion.bash
# 3. Restart your shell or source your .bashrc/.bash_profile.

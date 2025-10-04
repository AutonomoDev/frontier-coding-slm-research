#!/bin/bash

# Bash completion for `ollama run <model>`

_ollama_run_completion() {
  local models
  # Use ollama list to get available models.  Suppress errors to avoid
  # breaking the shell.  Output is assumed to be one model per line or
  # whitespace separated.
  models=$(ollama list 2>/dev/null | awk '{for (i=1; i<=NF; i++) print $i}')

  COMPREPLY=()
  for model in $models; do
    COMPREPLY+=("$model")
  done
}

complete -F _ollama_run_completion ollama run

# Installation:
# 1. Save this script to a file, e.g., /usr/local/etc/bash_completion.d/ollama-run
# 2. Source the file in your .bashrc or .bash_profile:
#    source /usr/local/etc/bash_completion.d/ollama-run
# 3. Restart your shell or source your .bashrc/.bash_profile for the changes to take effect.
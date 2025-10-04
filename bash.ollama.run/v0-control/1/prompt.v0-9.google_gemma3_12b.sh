#!/bin/bash

# ollama run completion script
#
# Usage: source /path/to/ollama_run_completion.bash
#
# This script provides completion for the ollama run command, listing available models.

_ollama_run_completion() {
  local curcontext="$CURCONTEXT"
  local models

  # Fetch available models from ollama list.  Handle potential errors silently.
  models=$(ollama list 2>/dev/null | awk '{print $1}')

  # If no models are found, just return.
  if [ -z "$models" ]; then
    return 0
  fi

  # If the cursor is at the beginning of the command (first word)
  if [ "$curcontext" -eq 1 ]; then
    _describe 'ollama run' 'Run an Ollama model'
    return
  fi

  # If the cursor is after "ollama run"
  if [ "$curcontext" -eq 2 ]; then
    _describe 'ollama run' 'Run an Ollama model'
    _add_completion 'run'
    return
  fi

  # If the cursor is after the model name, offer options for a prompt or other arguments
  if [[ "$curcontext" -gt 2 ]]; then
    _describe 'ollama run' 'Run an Ollama model'
    _add_completion 'run'
    _add_completion 'model'
    return
  fi

  # Complete available models.
  _add_completion "model"
  _describe 'ollama run' 'Run an Ollama model'

  # Add available models as completions.
  for model in $models; do
    _add_completion "$model"
  done
}

# Register the completion function.
complete -F _ollama_run_completion ollama run

# Installation snippet (to be placed in .bashrc or similar):
# source /path/to/ollama_run_completion.bash
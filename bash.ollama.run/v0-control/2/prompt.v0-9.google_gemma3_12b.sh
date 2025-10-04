#!/usr/bin/env bash

_ollama_run() {
  local curcontext="$CURRENT_CONTEXT"
  local models

  # Get the list of models from ollama list, handling potential errors
  models=$(ollama list 2>/dev/null | awk '{print $1}' | tr '\n' ' ')

  # If ollama list fails or returns nothing, provide a helpful message
  if [[ -z "$models" ]]; then
    echo "Error: Could not retrieve available models. Ensure 'ollama list' is working." >&2
    return 1
  fi

  # Complete the model name
  _describe 'ollama run <model>'
  _arguments \
    "1:model:$(printf '%s' "$models" | sed 's/ /"/g')"

  return 0
}

# Add completion function to the shell
if ! shopt -oq posix; then
  complete -o nospace -C "_ollama_run" ollama run
else
  _ollama_run
fi

# Installation snippet:
# To install, save this script to a file named `_ollama_run`
# and source it:
# source _ollama_run
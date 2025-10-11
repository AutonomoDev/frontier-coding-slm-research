#!/bin/bash
# This script provides bash completion for the `ollama run` command.
# It parses the output of `ollama list` to provide suggestions for model names.

# Function to get the list of available models
get_models() {
  # Run `ollama list` and parse the output to extract model names
  ollama list |
    sed '1d' | # Skip the header line
    cut -d ' ' -f 1 | # Extract the first column (model name)
    sort -u # Remove duplicates
}

# Function to perform the completion
_ollama_run_complete() {
  # Check if the current word is immediately after the `run` subcommand
  local cur prev
  
  # Attempt to use _get_comp_words_by_ref, but fall back if it is unavailable
  if command -v _get_comp_words_by_ref >/dev/null 2>&1; then
    _get_comp_words_by_ref "run"
  else
    # Fallback for systems without _get_comp_words_by_ref
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi
  

  # Check if we are completing immediately after the `run` command.
  if [[ "$prev" == "run" ]]; then
    # Get the list of available models
    local models=$(get_models)

    # Filter the models based on the current word
    local filtered_models
    if [[ -n "$cur" ]]; then
      filtered_models=$(echo "$models" | grep -i "^$cur")
    else
      filtered_models="$models"
    fi

    # Set the completion suggestions
    COMPREPLY=( $(compgen -W "$filtered_models" -- "$cur") )
  fi
}

# Register the completion function
complete -F _ollama_run_complete ollama

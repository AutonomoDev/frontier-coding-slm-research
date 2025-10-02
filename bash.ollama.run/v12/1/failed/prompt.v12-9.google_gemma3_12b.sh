#!/bin/bash

# Function to provide completions for the ollama run command
_ollama_completions() {
  local cur prev models matches sorted_matches

  # Check if the first word is "ollama" and the previous word is "run"
  if [[ "$1" != "ollama" || "$2" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Handle colons correctly: prevent Bash from splitting on ':'
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return 0
  fi

  # Get the list of models from ollama list
  models=()
  ollama list 2>/dev/null | while IFS= read -r line; do
    # Skip header and empty lines
    if [[ "$line" =~ ^NAME ]]; then
      continue
    fi
    if [[ -z "$line" ]]; then
      continue
    fi
    # Extract the model name (first column)
    model_name=$(echo "$line" | awk '{print $1}')
    models+=("$model_name")
  done

  # If no models are found, exit
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  # Find matches based on the current word
  matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Generate completions using compgen
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # CRITICAL: Fixes how suggestions display after colons.  Without this, no suggestions appear after a colon.
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama

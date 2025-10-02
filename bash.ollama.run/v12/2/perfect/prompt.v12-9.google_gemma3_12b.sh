#!/bin/bash

# Function to provide completions for the ollama run command
_ollama_completions() {
  local cur prev models matches sorted_matches
  
  # Check if the first word is "ollama" and the previous word is "run".
  # If not, exit early with no completions.
  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Handle colons correctly: prevent bash from splitting on colons.
  # Try to use _get_comp_words_by_ref if available.
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the 'ollama' command exists.
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return 0
  fi

  # Get the list of models from 'ollama list'.
  # Redirect errors to /dev/null.
  models=()
  while IFS= read -r line; do
    # Skip the header line and empty lines.
    if [[ "$line" =~ ^NAME\sID\sSIZE\sMODIFIED$ || -z "$line" ]]; then
      continue
    fi

    # Extract the model name (first column) using awk.
    model_name=$(echo "$line" | awk '{print $1}')

    # Add the model name to the models array.
    models+=("$model_name")
  done < <(ollama list 2>/dev/null)

  # If no models are found, exit early with no completions.
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  # Create an array of potential matches based on the current word.
  matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches alphabetically.
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
  
  # Generate the completions using compgen.
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # CRITICAL: Call __ltrim_colon_completions to handle colons in model names correctly.
  # Without this, completions will not show after the colon.
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_completions ollama

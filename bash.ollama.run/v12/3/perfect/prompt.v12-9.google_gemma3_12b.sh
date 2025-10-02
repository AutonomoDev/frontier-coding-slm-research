#!/bin/bash

# Function to provide completions for the ollama run command.
_ollama_completions() {
  local cur prev models matches sorted_matches

  # Check if the command is "ollama run".  If not, return.
  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons correctly.  Try _get_comp_words_by_ref.
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback if _get_comp_words_by_ref is not available.
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the ollama command exists.
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Get the list of models from ollama list. Redirect errors to /dev/null.
  models=()
  while IFS= read -r line; do
    # Skip header and empty lines.
    if [[ "$line" =~ ^NAME\s+ID\s+SIZE\s+MODIFIED$ || -z "$line" ]]; then
      continue
    fi

    # Extract the model name from the first column using awk.
    model_name=$(echo "$line" | awk '{print $1}')

    # Add the model name to the models array.
    models+=("$model_name")
  done < <(ollama list 2>/dev/null)

  # If no models are found, return.
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Create an array of matches based on the current word.
  matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == *"$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches alphabetically.
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Generate completions using compgen.
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # CRITICAL: Fix how suggestions display after colons.  This is ABSOLUTELY ESSENTIAL.
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the ollama command.
complete -F _ollama_completions ollama

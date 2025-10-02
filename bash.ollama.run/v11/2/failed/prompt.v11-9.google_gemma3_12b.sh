#!/bin/bash

# Function to provide completions for the ollama command.
_ollama_completions() {
  local cur prev command
  # Check if the command is "ollama" and the previous word is "run".
  command="$1"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "$command" != "ollama" || "$prev" != "run" ]]; then
    return 0  # Return early if the command is not ollama run.
  fi

  # Handle colons in model names using _get_comp_words_by_ref.
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without _get_comp_words_by_ref.
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Retrieve available models using 'ollama list'.
  local models_output
  models_output=$('ollama list' 2>/dev/null)

  # Check if ollama command exists and the ollama list command succeeded
  if [ -z "$models_output" ]; then
      COMPREPLY=()
      return 0
  fi

  local models
  models=()
  # Parse the output of 'ollama list' to extract model names.  Skip header row.
  while IFS= read -r line; do
    if [[ ! "$line" =~ ^NAME ]]; then
      models+=("${line%% *}") # Extract the first word (model name).
    fi
  done <<< "$models_output"

  # Filter model names based on the current word being completed.
  local matches
  matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == *"$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches alphabetically.
  local sorted_matches
  sorted_matches=($(printf "%s\n" "${matches[@]}" | sort))

  # Generate completion suggestions using compgen.
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # CRITICAL: Handle colon completion display correctly.  Required for proper parsing.
  __ltrim_colon_completions "$cur"

  return 0
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_completions ollama

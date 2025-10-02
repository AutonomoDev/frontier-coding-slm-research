#!/bin/bash

_ollama_completions() {
  # Check if the command is ollama run
  if [[ "$COMP_WORDS[1]" != "ollama" || "$COMP_WORDS[2]" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons in model names
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Get model names from ollama list
  local models=()
  ollama list 2>/dev/null | while IFS= read -r line; do
    # Skip header
    if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
      continue
    fi

    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    # Extract model name (first column)
    local model_name=$(echo "$line" | awk '{print $1}')

    # Add model name to the array if it's not empty
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done

  # If no models found, return
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Find matching models
  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Complete the matches
  COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

  # CRITICAL: Trim colons from suggestions to fix display issues after colons
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

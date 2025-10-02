#!/bin/bash

# Function to handle completions for the ollama command
_ollama_completions() {
  # Check if the command is ollama and the previous word is run
  if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
    return 0
  fi

  # Use _get_comp_words_by_ref to handle colons correctly
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the previous word is "run"
  if [[ "${prev}" != "run" ]]; then
    return 0
  fi

  # Local variable for model names
  local model_names=()
  local sorted_matches=()

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    echo "ollama command not found." >&2
    return 0
  fi

  # Retrieve model names from ollama list
  ollama list | awk 'NR>1 {print $1}' | while read -r model; do
    model_names+=("$model")
  done

  # Handle empty or failed ollama list output
  if [[ ${#model_names[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  # Filter model names based on the current word
  for model in "${model_names[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      sorted_matches+=("$model")
    fi
  done

  # Sort the matches
  sorted_matches=($(printf "%s\n" "${sorted_matches[@]}" | sort))

  # Generate completions
  COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

  # CRITICAL: Trim leading colons from completion display. This is essential for colons in model names.
  __ltrim_colon_completions "$cur"

  return 0
}

# Function to remove leading colons from completion display
__ltrim_colon_completions() {
  local cur="$1"
  local i
  for ((i=0; i<${#COMPREPLY[@]}; i++)); do
    if [[ "${COMPREPLY[i]}" == *:* ]]; then
      COMPREPLY[i]=${COMPREPLY[i]#:}
    fi
  done
}

# Register the completion function
complete -F _ollama_completions ollama

#!/bin/bash

# Function to handle completions for the ollama command
_ollama_completions() {
  # Check if the command is ollama and the previous word is run
  if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${COMP_WORDS[COMP_CWORD-1]}" != "run" ]]; then
    return 0
  fi

  # Use _get_comp_words_by_ref to correctly handle colons in model names
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if previous word is "run" after handling possible word splitting
  if [[ "${prev}" != "run" ]]; then
    return 0
  fi

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    echo "ollama command not found" >&2
    return 0
  fi

  # Retrieve model names from ollama list
  local ollama_list_output
  ollama_list_output=$(ollama list 2>/dev/null)

  # Check if ollama list output is empty or failed
  if [[ -z "$ollama_list_output" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Parse model names from ollama list output
  local -a model_names
  local i=0
  while IFS= read -r line; do
    # Skip header line
    if [[ "$i" -gt 0 ]]; then
      # Extract model name (first column)
      model_name=$(echo "$line" | awk '{print $1}')
      model_names+=("$model_name")
    fi
    i=$((i + 1))
  done <<< "$ollama_list_output"

  # Filter matches based on current input
  local -a sorted_matches
  for model_name in "${model_names[@]}"; do
    if [[ "$model_name" == "$cur"* ]]; then
      sorted_matches+=("$model_name")
    fi
  done
  sorted_matches=($(printf "%s\n" "${sorted_matches[@]}" | sort))

  # Generate completions
  COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

  # CRITICAL: Handle colon-separated completions display
  __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

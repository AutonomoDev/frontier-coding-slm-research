#!/bin/bash

_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev || {
    # Fallback if _get_comp_words_by_ref fails
    cur="${COMP_WORDS[2]}"
    prev="${COMP_WORDS[1]}"
  }

  local models
  command -v ollama &>/dev/null || {
    COMPREPLY=();
    return
  }

  # Get list of models from ollama list
  models=($(ollama list 2>/dev/null | awk 'NR>1 {print $1}'))

  # Filter models matching the current word
  local filtered_models
  filtered_models=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      filtered_models+=("$model")
    fi
  done

  # Sort the filtered models
  sorted_models=($(compgen -S "${filtered_models[@]}" -- "$cur"))

  # Set the completions
  COMPREPLY=( "${sorted_models[@]}" )

  # Fix colon display (MANDATORY)
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
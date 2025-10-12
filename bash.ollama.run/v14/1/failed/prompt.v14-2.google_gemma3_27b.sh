#!/bin/bash

_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev # Handle colons in model names

  # If _get_comp_words_by_ref fails, fallback to manual extraction
  if [[ -z "$cur" ]]; then
    cur="${COMP_WORDS[2]}"
  fi

  local models
  # Check if ollama command exists
  if command -v ollama &>/dev/null; then
    # Get list of models from ollama list, skipping the header line and extracting the first column
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  else
    # If ollama is not found, return an empty completion list
    COMPREPLY=();
    return
  fi

  # Filter models that match the current word
  local filtered_models
  filtered_models=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      filtered_models+=("$model")
    fi
  done

  # Sort the filtered models
  sorted_models=($(compgen -S "${filtered_models[@]}" -- "$cur"))

  # Set the completion list
  COMPREPLY=( "${sorted_models[@]}" )

  # Fix colon display (MANDATORY)
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
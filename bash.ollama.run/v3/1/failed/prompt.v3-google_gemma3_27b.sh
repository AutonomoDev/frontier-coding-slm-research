#!/bin/bash

_ollama_run_complete() {
  local cur prev words cword
  # Use _get_comp_words_by_ref if available, otherwise fallback
  if type _get_comp_words_by_ref > /dev/null 2>&1; then
    _get_comp_words_by_ref ollama run
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only activate after 'ollama run'
  if [[ "$prev" != "run" || "$words[0]" != "ollama" ]]; then
    return
  fi

  # Get model list once
  local models_output
  models_output=$(ollama list 2>/dev/null) # Suppress errors

  if [[ -z "$models_output" ]]; then
    return # No models available
  fi

  # Split output into an array, removing the header line
  local -a models
  IFS=$'\n' read -r -d '' -a models <<< "$models_output"
  models=("${models[@]:1}") # Skip the first line ("name")

  # Filter by prefix
  local -a filtered_models
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      filtered_models+=("$model")
    fi
  done

  # Sort alphabetically
  sorted_models=$(printf '%s\n' "${filtered_models[@]}" | sort)

  # Populate COMPREPLY
  COMPREPLY=( $(compgen -W "$sorted_models" -- "$cur") )
}

complete -F _ollama_run_complete ollama

# Installation:
# 1. Save this script to a file, e.g., ~/.ollama_completion.bash
# 2. Add the following line to your ~/.bashrc:
#    source ~/.ollama_completion.bash
# 3. Reload your .bashrc: source ~/.bashrc


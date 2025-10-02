#!/bin/bash

# Function: _ollama_completions
# Description: Provides completions for the 'ollama run' command, dynamically retrieving model names.
_ollama_completions() {
  local cur prev
  local models
  local sorted_matches
  local comp_words
  local i

  # Check if the command is 'ollama' and the previous word is 'run'.
  if [[ "$1" != "ollama" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Handle colons properly using _get_comp_words_by_ref or fallback.
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Complete only if the previous word is 'run'.
  if [[ "$prev" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Check if ollama command exists.
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return 0
  fi

  # Retrieve model names from 'ollama list'.
  models=$(ollama list)

  # Handle empty output from ollama list.
  if [[ -z "$models" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Extract model names and store in an array, skipping the header.
  read -r -d '' model_array < <(awk 'NR>1 {print $1}' <<< "$models")

  # Filter model names based on the current word.
  for i in "${!model_array[@]}"; do
    if [[ "${model_array[$i]}" == *"$cur"* ]]; then
      sorted_matches+=("${model_array[$i]}")
    fi
  done

  # Sort the matches.
  sorted_matches=$(printf "%s\n" "${sorted_matches}" | sort -u)

  # Generate completion suggestions using compgen.
  compgen -W "$sorted_matches" -- "$cur" >&2
  COMPREPLY=$(compgen -W "$sorted_matches" -- "$cur")

  # CRITICAL: Trim colons from the completion display.
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_completions ollama

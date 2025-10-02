#!/bin/bash

# Function to provide completions for the ollama command
_ollama_completions() {
  local cur prev
  local models
  local matches
  local sorted_matches
  local comp_cword comp_words

  # Check if the command is "ollama" and previous word is "run"
  if [[ "${COMP_CWORD}" -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Handle systems with and without bash-completion
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  if [[ "$prev" == "run" ]]; then
    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
      COMPREPLY=()
      return 0
    fi

    # Retrieve model names using ollama list
    models=$(ollama list 2>/dev/null)

    # Parse the output of ollama list, skipping the header row
    matches=()
    if [[ -n "$models" ]]; then
      while IFS= read -r line; do
        if [[ "$line" != "NAME ID SIZE MODIFIED" ]]; then
          matches+=("${line%% *}") # Extract model name (first column)
        fi
      done <<< "$models"
    fi

    # Filter matches based on the current word
    sorted_matches=()
    for match in "${matches[@]}"; do
      if [[ "$match" == *"$cur"* ]]; then
        sorted_matches+=("$match")
      fi
    done

    # Sort the matches
    sorted_matches=($(printf '%s\n' "${sorted_matches[@]}" | sort))

    # Generate completions using compgen
    compgen -W "$sorted_matches" -- "$cur" >&2
    COMPREPLY=("${sorted_matches[@]}")

    # CRITICAL: Handle colon completions display with __ltrim_colon_completions
    __ltrim_colon_completions "$cur"
  else
    COMPREPLY=()
  fi
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama

#!/bin/bash

_ollama_completions() {
  # Check if the first word is "ollama" and the previous word is "run".
  if [[ "$COMP_WORDS[1]" != "ollama" || "$COMP_WORDS[COMP_CWORD-1]" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons in model names.  Bash splits on colons by default,
  # so we need to tell it not to.  _get_comp_words_by_ref is preferred
  # if available (bash-completion version 2+), otherwise fallback to
  # basic COMP_WORDS.
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if ollama command exists.
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Local variables.
  local models=()
  local matches=()
  local sorted_matches=""

  # Read ollama list output and parse model names.
  ollama list 2>/dev/null | while IFS= read -r line; do
    # Skip header and empty lines.
    if [[ "$line" == "NAME ID SIZE MODIFIED" || -z "$line" ]]; then
      continue
    fi

    # Extract model name (first column).
    model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done

  # If no models found, return.
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Find matches for the current word.
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # If no matches found, return.
  if [[ ${#matches[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Sort the matches.
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Complete the word.
  COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

  # CRITICAL: Fix for colons.  Without this, suggestions won't show after a colon.
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

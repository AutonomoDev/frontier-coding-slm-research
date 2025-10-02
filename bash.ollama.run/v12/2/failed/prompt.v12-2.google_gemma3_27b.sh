#!/bin/bash

_ollama_completions() {
  local cur prev models matches sorted_matches

  # Check if the command is ollama run
  if [[ "$COMP_WORDS[1]" != "ollama" || "$COMP_WORDS[2]" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons in model names.  Bash splits on ':' by default, so we need to
  # tell it not to. _get_comp_words_by_ref is the preferred way if available.
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
  models=()
  while IFS= read -r line; do
    # Skip header line
    if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
      continue
    fi

    # Skip empty lines
    if [[ -z "$line" ]]; then
      continue
    fi

    # Extract model name (first column) using awk
    model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models are found, return
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Find matches
  matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Generate completions
  COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

  # CRITICAL: Trim leading colons from completions.  Without this, suggestions
  # after colons will not appear. This is because bash still splits on ':'
  # even after we prevent _get_comp_words_by_ref from doing so initially.
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

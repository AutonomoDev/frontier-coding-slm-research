#!/bin/bash

_ollama_completions () {
  # Check subcommand
  if [[ "$COMP_WORDS" != "ollama run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons (important)
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Get model names
  local models=( )
  while IFS=$'\n' read -r line; do
    if [[ "$line" =~ ^NAME ]]; then
      continue
    elif [[ "$line" =~ ^[[:space:]]*$ ]]; then
      continue
    else
      local model=$(echo "$line" | awk '{print $1}')
      models+=( "$model" )
    fi
  done <<< "$(ollama list 2>/dev/null)"

  # No matches
  if [[ "${#models[@]}" -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Matches
  local matches=( )
  for model in "${models[@]}"; do
    if [[ "$model" =~ ^"$cur" ]]; then
      matches+=( "$model" )
    fi
  done

  # Sort matches
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Set COMPREPLY
  compgen -W "$sorted_matches" -- "$cur"

  # Critical colon fix (do not skip)
  __ltrim_colon_completions "$cur"
}

# Register completions
complete -F _ollama_completions ollama

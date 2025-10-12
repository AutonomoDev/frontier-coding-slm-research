#!/bin/bash

_ollama_completions() {
  local cur prev models

  # Check if command is "ollama run" - CRITICAL CHECK!
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Handle colons - prevent bash from splitting on :
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama exists
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  # Parse ollama list output - skip header, extract model names
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  if [[ -z "$models" ]]; then
    COMPREPLY=();
    return
  fi

  # Generate completions based on the current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort the completions alphabetically
  COMPREPLY=($(printf '%s\n' "${COMPREPLY[@]}" | sort))

  # Fix colon display - MANDATORY!
  __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
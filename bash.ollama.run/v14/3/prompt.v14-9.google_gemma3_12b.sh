#!/bin/bash

_ollama_completions() {
  local cur prev opts models

  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Handle colons - use _get_comp_words_by_ref if available
  if type -t _get_comp_words_by_ref >/dev/null 2>&1; then
    _get_comp_words_by_ref -n : cur prev
  else
    # Fallback: manual extraction from COMP_WORDS (less reliable with complex shells)
    prev="${COMP_WORDS[COMP_CWORD-2]}"
    cur="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if ollama command exists
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=()
    return
  fi

  # Get list of models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  if [ -z "$models" ]; then
    COMPREPLY=()  # No models found
    return
  fi

  # Filter models matching current prefix
  opts=$(echo "$models" | grep "^$cur")

  # Sort results
  opts=$(echo "$opts" | sort)

  # Generate completions using compgen
  COMPREPLY=( $(compgen -W "$opts" -- "$cur") )

  # Fix colon display - MANDATORY!
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

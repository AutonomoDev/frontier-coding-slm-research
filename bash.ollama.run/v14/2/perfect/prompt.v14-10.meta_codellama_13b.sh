#!/bin/bash

_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Handle colons in model names
  _get_comp_words_by_ref -n : cur prev

  # Parse ollama list output
  if command -v ollama &>/dev/null; then
    local models=$(ollama list 2>/dev/null | awk 'NR>1{print $1}')
  fi

  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "${cur}"))

  # Fix colon display
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
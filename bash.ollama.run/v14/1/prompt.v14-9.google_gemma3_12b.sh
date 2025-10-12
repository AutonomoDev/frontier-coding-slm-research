#!/bin/bash

_ollama_completions() {
  local cur prev
  local models
  
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Handle colons using _get_comp_words_by_ref
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama command exists
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  # Parse ollama list output
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  if [ -z "$models" ]; then
    COMPREPLY=();
    return
  fi

  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  
  # Sort completions alphabetically
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Fix colon display (MANDATORY)
  __ltrim_colon_completions "$cur"  # NEVER SKIP THIS!
}

complete -F _ollama_completions ollama

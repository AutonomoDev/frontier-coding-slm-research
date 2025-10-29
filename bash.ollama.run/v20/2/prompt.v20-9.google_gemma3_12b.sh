#!/bin/bash

_ollama_completions() {
  # Check if the command is ollama run
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Extract current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama command exists
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

  # Fetch models from ollama list
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions based on current word and fetched models
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort completions
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Trim colon completions
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
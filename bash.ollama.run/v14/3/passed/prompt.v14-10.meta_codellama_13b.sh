#!/bin/bash

# Bash completion script for ollama run <model>

_ollama_completions() {
  local cur prev models i

  # Split current word into an array of words
  COMPREPLY=()
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Check if command is "ollama run" and exit early if not
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Try to use _get_comp_words_by_ref -n : cur prev for colon handling
  if [[ ${cur} == *:* ]]; then
    COMPREPLY=( $( compgen -W "$( ollama list 2>/dev/null | awk '{print $1}' )" -- ${cur} ) )
  # Fallback to manual extraction from COMP_WORDS if _get_comp_words_by_ref fails
  else
    models=( $( ollama list 2>/dev/null | awk 'NR>1{print $1}' ) )
    for i in "${models[@]}"; do
      [[ "$i" == ${cur}* ]] && COMPREPLY+=("$i")
    done
  fi

  # __ltrim_colon_completions at the end to fix colon display
  __ltrim_colon_completions "${prev}"
}

# Register completion function for ollama run command only
complete -F _ollama_completions ollama run
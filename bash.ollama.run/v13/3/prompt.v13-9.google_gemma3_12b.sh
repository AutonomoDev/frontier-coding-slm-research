#!/bin/bash

_ollama_completions() {
  local cur prev words
  COMPREPLY=()
  cur="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  words=("${COMP_WORDS[@]}")

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  COMPREPLY=()
  local models
  models=($(ollama list | tail -n +2 | awk '{$1=$1; print}') )

  for model in "${models[@]}"; do
    COMPREPLY+=("$model")
  done

  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

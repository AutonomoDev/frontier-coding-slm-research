#!/bin/bash

_ollama_completion() {
  local cur prev words
  COMPREPLY=()
  cur="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  words=("${COMP_WORDS[@]}")

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  local models
  models=($(ollama list | tail -n +2 | awk '{print $1}' | grep -v '^$'))

  COMPREPLY=( "${words[*]}" )
  COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completion ollama

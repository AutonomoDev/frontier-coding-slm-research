#!/bin/bash

_ollama_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  COMPREPLY=()
  local models
  models=($(ollama list | tail -n +2 | awk '{print $1}' | grep -v '^$'))

  if [[ "$cur" == "-" ]]; then
    COMPREPLY=( --${COMPREPLY[@]} )
    return
  fi

  local words
  words=("${COMPREPLY[@]}")

  if [[ "$cur" == "ollama" ]]; then
    COMPREPLY=("run" "list" "serve" "pull" "run" )
    return
  fi

  if [[ "$cur" == "run" ]]; then
    COMPREPLY=("${models[@]}")
    return
  fi

  # Complete other subcommands
  if [[ "$cur" == "list" ]]; then
      COMPREPLY=("${COMPREPLY[@]}")
      return
  fi
  if [[ "$cur" == "serve" ]]; then
      COMPREPLY=("${COMPREPLY[@]}")
      return
  fi

  if [[ "$cur" == "pull" ]]; then
    COMPREPLY=("${COMPREPLY[@]}")
    return
  fi

  __ltrim_colon_completions "$cur"
}

if ! type -t complete >/dev/null 2>&1; then
  complete -F _ollama_completion ollama
else
  _ollama_completion
fi

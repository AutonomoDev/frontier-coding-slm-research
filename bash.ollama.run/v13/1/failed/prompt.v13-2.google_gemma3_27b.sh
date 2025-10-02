#!/bin/bash

_ollama_run_completions() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  local models
  models=$(ollama list | tail -n +2 | grep -v '^$' | awk '{print $1}')

  COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_run_completions ollama run


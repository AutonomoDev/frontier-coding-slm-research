#!/bin/bash

_ollama_run_completions() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return 1
  fi

  if [[ $COMP_CWORD -eq 2 ]]; then
    ollama list --format '{{.Name}}' | tail -n +2 | grep -v '^$' | while read -r model; do
      COMPREPLY+=("$model")
    done
  fi
}

complete -F _ollama_run_completions ollama

__ltrim_colon_completions() {
  local cur="$1"
  COMPREPLY=( $(compgen -W "$cur" -- "${COMP_WORDS[@]}") )
}

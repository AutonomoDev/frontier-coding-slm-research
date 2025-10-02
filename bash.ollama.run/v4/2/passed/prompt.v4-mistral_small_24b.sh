#!/bin/bash

_ollama_run_completions() {
  local cur prev words cword
  _init_completion || return

  # Check if the second word is 'run'
  if [[ ${COMP_WORDS[1]} != "run" ]]; then
    return
  fi

  # Get the current word being completed
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Extract model names from `ollama list` output
  local models
  models=$(ollama list | awk 'NR>1 {print $1}')

  # Filter models based on the current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  return 0
}

complete -F _ollama_run_completions ollama

# To enable this script, source it in your shell or add it to your completion scripts directory.

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run_completions` that is triggered when completing the `run` subcommand of `ollama`. It parses the output of `ollama list`, extracts model names, and filters them based on the current word being typed. The completions are then provided using `COMPREPLY`.


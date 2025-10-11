#!/bin/bash

# Bash completion for ollama run <model>

_ollama_run_completion() {
  local models
  local cur prev opts

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "$prev" == "ollama" && "$cur" == "run" ]]; then
    # Get the list of models from ollama list
    models=$(ollama list 2>/dev/null | awk '/^[a-zA-Z0-9:]+/ {print $1}')

    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi

  return 0
}

complete -F _ollama_run_completion ollama

# Installation:
# 1. Save this script to a file, e.g., ~/.ollama_completion.bash
# 2. Add the following line to your ~/.bashrc or ~/.bash_profile:
#    source ~/.ollama_completion.bash
# 3. Restart your terminal or source your ~/.bashrc/.bash_profile

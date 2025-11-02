#!/bin/bash
# Bash completion for `ollama run <model>`

_ollama_run_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local models=()

  # Get the list of available models using ollama list
  if ollama list > /dev/null 2>&1; then
    models=($(ollama list)) # Split output into array, whitespace delimited
  fi

  # Filter models based on the current word prefix
  COMPREPLY=($(compgen -W "${models[@]}" -- "$cur"))
}

complete -f ollama_run_completion ollama run

# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama-run.bash
# 2. Source it: source ~/.bash_completion.d/ollama-run.bash
# 3. Or, source ~/.bashrc or ~/.bash_profile to make it permanent.

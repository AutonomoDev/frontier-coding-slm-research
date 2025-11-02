#!/bin/bash

_ollama_run() {
  # COMPREPLY is an array of possible completions
  COMPREPLY=()

  # Get the current word prefix from $2
  local prefix="${COMP_WORDS[1]}"

  # Parse the output of ollama list into an array of model names
  local -a models=( $(ollama list) )

  # Filter the models by the current prefix and add them to COMPREPLY
  for model in "${models[@]}"; do
    if [[ "$model" == "$prefix"* ]]; then
      COMPREPLY+=("$model")
    fi
  done
}
complete -F _ollama_run ollama run
```
Installation: Drop the script into your $HOME/.bash_completion directory or source it in your shell profile.
# To activate, either open a new terminal window or type `source ~/.bash_completion`


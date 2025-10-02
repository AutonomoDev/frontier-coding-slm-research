#!/bin/bash

_ollama_run () {
  local cur prev models output

  # Get current word being completed
  _get_comp_words_by_ref -n = cur

  # Get previous word
  _get_comp_words_by_ref -p1 prev

  if [[ $prev == "run" && $cur != "" ]]; then
    # Run ollama list and capture output in variable
    output=$(ollama list) || return

    # Split output into array of models
    IFS=$'\n' read -r -d '' -a models <<<"$output"

    # Filter models by prefix
    for model in "${models[@]}"; do
      if [[ $model == "$cur"* ]]; then
        COMPREPLY+=("${model}")
      fi
    done

    # Sort and assign to COMPREPLY
    IFS=$'\n' compgen -W "$(sort <<<"${COMPREPLY[*]}")" -- "$cur"
  fi
}
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#To activate the completion, save this script to a file (e.g., `~/.bash_completion/_ollama`) and source it from your `.bashrc` file:
#```bash
#source ~/.bash_completion/_ollama
#```


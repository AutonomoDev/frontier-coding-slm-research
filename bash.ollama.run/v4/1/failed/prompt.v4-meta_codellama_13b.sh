#!/bin/bash

_ollama_run () {
  # Get the list of available local models
  models=$(ollama list | awk '{print $1}' | sed '1d')

  # Check if the word being completed is "run"
  if [[ ${COMP_WORDS[0]} == "run" ]]; then
    # Extract the current word being completed
    cur=${COMP_WORDS[$COMP_CWORD]}

    # Filter the model names based on the user input
    filtered=$(echo "$models" | grep "^$cur")

    # Provide completion suggestions for the filtered models
    COMPREPLY=($(compgen -W "$filtered" -- $cur))
  fi
}

complete -F _ollama_run ollama

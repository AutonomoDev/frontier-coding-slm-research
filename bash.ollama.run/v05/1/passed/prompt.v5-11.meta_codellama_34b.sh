#!/bin/bash

# This is a Bash completion script for the `ollama run` command.

# This function parses the output of `ollama list` and extracts only the model names from the first column.
_get_models() {
  ollama list | awk 'NR > 1 {print $1}'
}

# This function generates the completion suggestions for the `ollama run` command based on the current word being completed.
_ollama_run() {
  local cur prev words cword split
  _init_completion || return

  # If the user has not typed anything yet, suggest all available model names.
  if [[ "$cur" == "" ]]; then
    COMPREPLY=($(_get_models))
    return
  fi

  # Otherwise, only suggest model names that start with the current word.
  COMPREPLY=($(compgen -W "$(_get_models)" -- "$cur"))
}

# Register the _ollama_run function as a completion for the `ollama run` command.
complete -F _ollama_run ollama run

#!/bin/bash
# Bash completion script for the `ollama run` command.

# Ensure this script is sourced, not executed directly.
if [[ $- != *i* ]]; then
  return
fi

# Function to get the list of available models.
get_ollama_models() {
  ollama list | awk 'NR > 1 {print $1}'
}

# Completion function for the `ollama run` command.
_ollama_run_completion() {
  local cur prev opts
  COMPREPLY=()  # Initialize the completion array.
  cur="${COMP_WORDS[COMP_CWORD]}"  # The word being completed.
  prev="${COMP_WORDS[COMP_CWORD-1]}"  # The previous word.

  # Only activate completion after the `run` subcommand.
  if [[ "$prev" == "run" ]]; then
    # Get the list of available models.
    local models=$(get_ollama_models)

    # Filter the models based on the current word.
    if [[ -n "$cur" ]]; then
      COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    else
      COMPREPLY=( $(compgen -W "$models" --) ) # show all models if no prefix entered.
    fi

    # Remove any duplicate suggestions.
    COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort -u) )
  fi
}

# Register the completion function.
complete -F _ollama_run_completion ollama


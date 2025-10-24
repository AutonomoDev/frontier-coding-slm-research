#!/bin/bash

# Description: Bash completion for ollama run command.
# Author: [Your Name]
#
# This script provides autocompletion suggestions for the model names
# when the `ollama run` command is used.

# Source the bash-completion library.
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

# Function to get the list of available models.
_ollama_run_models() {
  local models
  models=$(ollama list | tail -n +2 | cut -d' ' -f1) # Extract model names from the second line onwards

  # Filter based on the current word.
  local cur="${COMP_WORDS[$COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  return 0
}

# Check if _get_comp_words_by_ref is available and use it.
# Fallback to manual `prev` and `cur` setting if it's missing.
if type -t _get_comp_words_by_ref >/dev/null 2>&1; then
  _get_comp_words_by_ref "$@"
else
  # Manual fallback.
  cur="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"
fi

# Define the completion function.
_ollama_run_completion() {
  local prevword="$prev"
  local curword="$cur"

  # Trigger completion only when the user is typing the model name
  # after the "run" subcommand.
  if [[ "$prevword" == "run" ]]; then
    _ollama_run_models
  fi
  return 0
}


# Register the completion function.
complete -F _ollama_run_completion ollama run


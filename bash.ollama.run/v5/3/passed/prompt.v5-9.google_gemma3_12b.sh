#!/bin/bash

# Enable completion for the ollama run command.
# This script provides autocompletion for model names.

# Source the bash-completion framework if it's not already loaded.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Function to get the list of available models.
_ollama_run_list_models() {
  # Run ollama list and extract the model names.
  local models
  models=$(ollama list | awk 'NR>1 {print $1}')

  # Remove duplicates.  Sort and then use uniq
  models=$(echo "$models" | sort | uniq)

  echo "$models"
}

# Completion function for ollama run.
_ollama_run_completion() {
  local cur prev words
  # Check if the user is trying to complete the model name after 'ollama run'.
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get the current word being completed.
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Get the list of available models.
    local available_models
    available_models=$(_ollama_run_list_models)

    # Filter the available models based on the current word.
    local filtered_models
    filtered_models=()
    for model in $available_models; do
      if [[ "$model" == "$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done

    # Set the completion suggestions.
    COMPREPLY=("${filtered_models[@]}")
  fi
}

# Register the completion function.
complete -F _ollama_run_completion ollama run


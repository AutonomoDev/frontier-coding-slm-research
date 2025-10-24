#!/bin/bash

# Source the bash-completion library.  This must be done before any
# completion code is defined.
# source /usr/share/bash-completion/bash_completion

# Function to get available models
_ollama_run_completions() {
  local cur prev words
  local models
  local completion_options

  # Get the current word and previous word
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  words=("${COMP_WORDS[@]}")

  # Check if the command is ollama run
  if [[ "${words[1]}" == "run" ]]; then

    # Get the list of available models
    models=$(ollama list | tail -n +2 | cut -d' ' -f1)

    # Filter the models based on the current word
    if [[ -n "$cur" ]]; then
      completion_options=$(echo "$models" | grep "^$cur")
    else
      completion_options="$models"
    fi

    # Remove duplicates
    completion_options=$(echo "$completion_options" | sort -u)

    # Complete the word
    COMPREPLY=("${completion_options}")
  fi
}

# Tell the system about the completion function
complete -F _ollama_run_completions ollama run


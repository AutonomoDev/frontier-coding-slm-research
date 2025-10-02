#!/bin/bash
# This is a Bash completion script for the `ollama run` command.
# The script must provide autocompletion suggestions for model names when a user types `ollama run ` and presses `<TAB>`.

# Define the function that will be used to complete the `ollama run` command.
_ollama_run() {
  # Get the first word after `run`, which should be the model name.
  local model_name="${COMP_WORDS[2]}"

  # Use the `ollama list` command to get a list of available models.
  # We need to skip the header line, so we use `tail -n +2`.
  local models="$(ollama list | tail -n +2)"

  # Define an array to store the model names.
  COMPREPLY=()

  # Loop through each model in the list and check if it starts with the user-provided name.
  while read -r model; do
    # Extract the model name from the first column of the `ollama list` output.
    local model_name="${model%%:*}"

    # If the current model name starts with the user-provided name, add it to the list of suggestions.
    if [[ "$model_name" == "$model_name"* ]]; then
      COMPREPLY+=("$model_name")
    fi
  done <<< "$models"
}

# Register the completion function for the `ollama run` command.
complete -F _ollama_run ollama run


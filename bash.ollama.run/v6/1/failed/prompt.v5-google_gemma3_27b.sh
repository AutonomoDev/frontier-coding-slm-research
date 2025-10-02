#!/bin/bash
# This script provides bash completion for the `ollama run` command.
# It autocompletes model names after the `ollama run ` command.

# Function to get available model names from `ollama list`.
get_ollama_models() {
  # Execute `ollama list` and parse the output.
  ollama list |
    # Skip the header line.
    tail -n +2 |
    # Extract the model name (first column).
    cut -d ' ' -f 1 |
    # Remove any leading/trailing whitespace.
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Main completion function.
_ollama_run_completion() {
  # Get the current word being completed.
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Check if the previous word is "run" and the first word is "ollama".
  if [[ "$prev" == "run" && "$COMP_WORDS[0]" == "ollama" ]]; then
    # Get the list of available models.
    local models=$(get_ollama_models)

    # Create an array to store the filtered models.
    local filtered_models=()

    # Filter the models based on the current word.
    while IFS= read -r model; do
      if [[ "$model" == "$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done <<< "$models"

    # Set the completion suggestions.
    COMPREPLY=(${filtered_models[@]})
  fi
}

# Register the completion function.
complete -F _ollama_run_completion ollama


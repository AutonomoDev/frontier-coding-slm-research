#!/bin/bash
# This script provides bash completion for the `ollama run` command.
# It parses the output of `ollama list` and provides suggestions for model names.

# Function to get the list of available models
get_models() {
  # Execute `ollama list` and parse the output.
  ollama list |
    # Skip the header line
    tail -n +2 |
    # Extract the first column (model name) using cut.
    cut -d ' ' -f 1 |
    # Remove leading/trailing whitespace
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Completion function
_ollama_run_completion() {
  # Get the current word being completed
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Check if the previous word is `run` and the first word is `ollama`.
  if [[ "$prev" == "run" && "$COMP_WORDS[0]" == "ollama" ]]; then
    # Get the list of available models
    local models=$(get_models)

    # Create an associative array to store the models for filtering
    local -a model_array
    IFS=$'\n' read -r -d '' -a model_array <<< "$models"

    # Filter the models based on the current word
    local -a filtered_models
    for model in "${model_array[@]}"; do
      if [[ "$model" == "$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done

    # Remove duplicate suggestions
    local -a unique_models
    local -i seen
    for model in "${filtered_models[@]}"; do
      seen=0
      for unique_model in "${unique_models[@]}"; do
        if [[ "$model" == "$unique_model" ]]; then
          seen=1
          break
        fi
      done
      if [[ "$seen" -eq 0 ]]; then
        unique_models+=("$model")
      fi
    done

    # Set the completion suggestions
    COMPREPLY=( "${unique_models[@]}" )
  fi
}

# Register the completion function
complete -F _ollama_run_completion ollama


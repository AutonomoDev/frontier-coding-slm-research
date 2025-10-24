#!/bin/bash
# This script provides bash completion for the `ollama run` command.
# It autocompletes model names based on the output of `ollama list`.

# Check if the script is sourced.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
  return
fi

# Function to get the list of available models.
get_models() {
  # Get the output of `ollama list`.
  ollama_list=$(ollama list 2>/dev/null)

  # Initialize an empty array to store the model names.
  local models=()

  # Skip the header line and extract model names from each line.
  while IFS= read -r line; do
    if [[ "$line" =~ ^NAME ]]; then
      continue  # Skip the header line
    fi

    # Extract the first field (model name) using cut.
    model_name=$(echo "$line" | cut -d' ' -f1)

    # Add the model name to the array.
    models+=("$model_name")
  done <<< "$ollama_list"

  # Return the array of model names.
  echo "${models[@]}"
}

# Main completion function.
_ollama_run_completion() {
  # Check if the current word is "run".
  if [ "${COMP_WORDS[1]}" != "run" ]; then
    return
  fi

  # Get the current word being completed.
  local cur="${COMP_WORDS[2]}"

  # Get the list of available models.
  local models=$(get_models)

  # Initialize an empty array to store the filtered completion suggestions.
  local completions=()

  # Filter the models based on the current word.
  for model in $models; do
    if [[ "$model" == "$cur"* ]]; then
      completions+=("$model")
    fi
  done

  # Set the completion suggestions.
  COMPREPLY=( "${completions[@]}" )
}

# Register the completion function.
complete -F _ollama_run_completion ollama


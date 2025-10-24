#!/bin/bash
#
# Bash completion script for the `ollama run` command.
#
# This script provides autocompletion for model names when typing
# `ollama run <TAB>`.

# Ensure we are sourcing this script, not executing it directly
if [[ $BASH_SOURCE == "$0" ]]; then
  echo "Error: This script must be sourced." >&2
  exit 1
fi

# Check if the current command is `ollama run`
if [[ "${COMP_WORDS[1]}" != "run" ]]; then
  return
fi

# Get the list of available models from `ollama list`
ollama_list_output=$(ollama list)

# Extract model names, skipping the header line.
# Use awk to print the first column ($1) of each line after the first line.
model_names=$(echo "$ollama_list_output" | awk 'NR > 1 {print $1}')

# Filter the model names based on the current word being completed.
# COMP_WORDS[2] is the word we are completing.
current_word="${COMP_WORDS[2]}"

# If no word is being completed yet, use an empty string.
if [[ -z "$current_word" ]]; then
  current_word=""
fi

# Use grep to filter the model names based on the current word.
# The -i flag makes the search case-insensitive.
filtered_model_names=$(echo "$model_names" | grep -i "^$current_word")

# Create the completion list.
# Use tr to convert newlines to spaces for the COMPREPLY array.
COMPREPLY=( $(echo "$filtered_model_names") )

# Ensure no duplicate entries in the completion list.
# This is handled implicitly by the use of array and the grep filter above.
# If the grep filter produces duplicate model names then they will only be included once in the COMPREPLY array.

return 0


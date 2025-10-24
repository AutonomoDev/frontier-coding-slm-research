#!/bin/bash
# This script provides bash completion for the `ollama run` command.
# It completes model names based on the output of `ollama list`.

# Check if the second word is 'run'. This ensures that the completion
# logic is only triggered after the 'run' subcommand.
if [[ ${COMP_WORDS[1]} == "run" ]]; then
  # Get the output of `ollama list`.
  ollama_list_output=$(ollama list)

  # Parse the output of `ollama list` and extract the model names.
  # Skip the header line and extract the first column.
  model_names=$(echo "$ollama_list_output" | tail -n +2 | cut -d ' ' -f 1)

  # Filter the model names based on the current word being completed.
  # ${COMP_WORDS[2]} is the current word the user is typing after 'ollama run'.
  current_word="${COMP_WORDS[2]}"

  # Filter the model names using grep.
  filtered_model_names=$(echo "$model_names" | grep -i "^$current_word")

  # Remove duplicate model names using sort and uniq.
  unique_model_names=$(echo "$filtered_model_names" | sort -u)

  # Set the completion suggestions in the `COMPREPLY` array.
  COMPREPLY=( $(echo "$unique_model_names") )
fi

# Exit gracefully.
exit 0


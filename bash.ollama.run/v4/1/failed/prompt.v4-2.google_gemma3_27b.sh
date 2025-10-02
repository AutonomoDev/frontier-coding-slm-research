#!/bin/bash
# Bash completion script for the `ollama run` command.

# Check if the current word is 'run' after the 'ollama' command.
# If not, exit without providing any completions.
if [[ ${COMP_WORDS[1]} != "run" ]]; then
  return
fi

# Get the output of `ollama list`.
ollama_list_output=$(ollama list)

# Extract model names, skipping the header line.
model_names=()
while IFS= read -r line; do
  if [[ "$line" == "NAME"* ]]; then
    continue  # Skip the header line
  fi
  # Use awk to extract the first column (model name).
  model_name=$(echo "$line" | awk '{print $1}')
  model_names+=("$model_name")
done <<< "$ollama_list_output"

# Get the current word being completed.
current_word="${COMP_WORDS[2]}"

# Filter model names based on the current word.
filtered_model_names=()
for model_name in "${model_names[@]}"; do
  if [[ "$model_name" == "$current_word"* ]]; then
    filtered_model_names+=("$model_name")
  fi
done

# Remove duplicate model names.
unique_model_names=()
seen=()
for model_name in "${filtered_model_names[@]}"; do
  if [[ ! " ${seen[@]} " =~ " ${model_name} " ]]; then
    unique_model_names+=("$model_name")
    seen+=("$model_name")
  fi
done

# Set the completion suggestions.
COMPREPLY=( "${unique_model_names[@]}" )

return 0


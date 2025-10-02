#! /usr/bin/env bash

if [[ ${COMP_WORDS[1]} != "run" ]]; then
  return  # Exit if the second word is not 'run'
fi

# Fetch available models from ollama list command
local_models=$(ollama list | awk 'NR>1 {print $1}')

# Generate possible completions based on the current input context
COMPREPLY=()
current_word=${COMP_WORDS[COMP_CWORD]}
completions=$(echo "$local_models" | grep "^$current_word")

# Populate COMPREPLY with unique, filtered suggestions
while IFS= read -r line; do
  if [[ -n $line ]]; then
    COMPREPLY+=("$line")
  fi
done <<< "$(echo "$completions" | sort -u)"


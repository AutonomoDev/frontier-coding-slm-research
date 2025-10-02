#! /usr/bin/env bash

if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 1
fi

# Get a list of models from `ollama list` command output
models=$(ollama list | awk 'NR>1 {print $1}')

# Convert the list of models into an array for easier manipulation
readarray -t model_list <<< "$models"

# Extract the word being completed, if any
word="${COMP_WORDS[COMP_CWORD]}"

# Filter suggestions based on the current word being typed
filtered_suggestions=()
for suggestion in "${model_list[@]}"; do
    if [[ $suggestion == "$word"* ]]; then
        filtered_suggestions+=("$suggestion")
    fi
done

# Remove duplicates and ensure unique suggestions
unique_suggestions=$(echo "${filtered_suggestions[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

# Set the completion results based on the extracted word
if [[ ${#unique_suggestions} -gt 0 ]]; then
    COMPREPLY=($(compgen -W "$unique_suggestions" -- $word))
else
    COMPREPLY=()
fi

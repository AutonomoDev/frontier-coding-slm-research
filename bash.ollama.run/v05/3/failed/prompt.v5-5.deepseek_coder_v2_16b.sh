#! /usr/bin/env bash

if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
fi

# Get the word being completed (current input)
cur="${COMP_WORDS[COMP_CWORD]}"

# Fetch the list of models from ollama list command
models=$(ollama list | awk 'NR>1 {print $1}')

# Generate possible completions based on the current input
completions=()
for model in $models; do
    if [[ "$model" == "$cur"* ]]; then
        completions+=("$model")
    fi
done

# Remove duplicates and sort the list of completions
sorted_completions=$(echo "${completions[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')

# Use COMPREPLY to provide suggestions
COMPREPLY=($(compgen -W "$sorted_completions" -- $cur))


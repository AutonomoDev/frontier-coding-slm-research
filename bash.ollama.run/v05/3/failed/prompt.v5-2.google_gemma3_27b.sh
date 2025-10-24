#!/bin/bash
# This script provides bash completion for the `ollama run` command.

_ollama_run_list_models() {
    # Check if the second word is 'run'.
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
      return
    fi

    # Get the output of `ollama list`.
    ollama_list_output=$(ollama list)

    # Parse the output of `ollama list` to extract model names, skipping the header.
    # Use tail to skip the first line (header) and then use cut to extract the first column.
    model_names=$(echo "$ollama_list_output" | tail -n +2 | cut -d ' ' -f 1)

    # Filter the model names based on the current word being completed.
    current_word="${COMP_WORDS[2]}"
    filtered_models=""

    if [ -n "$current_word" ]; then
      # Iterate over the model names and filter based on the current word.
      while read -r model_name; do
        if [[ "$model_name" == "$current_word"* ]]; then
          filtered_models+="$model_name "
        fi
      done <<< "$model_names"
    else
      filtered_models="$model_names"
    fi

    # Remove any duplicate model names.
    unique_models=$(echo "$filtered_models" | tr ' ' '\n' | sort -u | tr '\n' ' ')

    # Set the completion suggestions.
    COMPREPLY=($unique_models)

    # Return 0 to indicate success.
    return 0
}

# Register the completion function.
complete -F _ollama_run_completion ollama run


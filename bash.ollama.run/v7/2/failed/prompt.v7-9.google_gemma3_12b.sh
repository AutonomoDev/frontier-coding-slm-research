# Bash completion script for ollama run

# Function to get the list of models from ollama list
_ollama_get_models() {
  # Capture the output of ollama list and parse it to extract model names
  local models
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Check if the command succeeded and returned a list of models
  if [ -z "$models" ]; then
    return 1  # Indicate failure
  fi

  # Print the model names, one per line
  echo "$models"
  return 0 # Indicate success
}

# Completion function for ollama run
_ollama_run_completion() {
  # Save the current value of COMP_WORDBREAKS
  old_wb=$COMP_WORDBREAKS

  # Remove ':' from COMP_WORDBREAKS to handle model names like codellama:32b
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}/

  # Get the list of available models
  local models
  models=($(_ollama_get_models))

  # If ollama list fails or returns nothing, exit gracefully
  if [ $? -ne 0 ]; then
    COMPREPLY=()
    return 0
  fi

  # Find the index of "run" in COMP_WORDS
  local run_index
  run_index=0
  while [[ $run_index -lt ${#COMP_WORDS[@]} && "${COMP_WORDS[$run_index]}" != "run" ]]; do
    ((run_index++))
  done

  # Trigger completion only if we're completing the token after "run"
  if [[ $COMP_CWORD == $((run_index + 1)) ]]; then
    # Use compgen to filter the list of models based on the current word
    local cur=${COMP_WORDS[$((COMP_CWORD - 1))]}

    # Generate suggestions based on the current word
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Remove duplicates from the suggestions
    COMPREPLY=($(echo "${COMPREPLY[*]}" | awk '!seen[$0]++'))
  fi

  # Restore the original value of COMP_WORDBREAKS
  COMP_WORDBREAKS=$old_wb

  return 0
}

# Register the completion function with the complete command
complete -F _ollama_run_completion ollama


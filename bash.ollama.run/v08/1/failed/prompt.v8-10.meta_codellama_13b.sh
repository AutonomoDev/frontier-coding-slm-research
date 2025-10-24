#!/bin/bash

_ollama_run() {
  # MUST save and restore COMP_WORDBREAKS in ALL code paths
  local old_wb="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
  
  # Find the exact position of "run" in COMP_WORDS array
  local run_index=0
  while [ "$run_index" -lt "${#COMP_WORDS[@]}" ]; do
    if [[ "${COMP_WORDS[run_index]}" == "run" ]]; then
      break
    fi
    ((run_index++))
  done
  
  # Only trigger completion when COMP_CWORD == run_index + 1
  if [ "$COMP_CWORD" -eq $((run_index + 1)) ]; then
    local models=()
    
    # Parse ollama list output for model names
    while IFS= read -r line; do
      # Remove the "NAME" label and split the rest by spaces
      local fields=("${line#*: }")
      
      # Add the first field (model name) to the models array
      models+=("${fields[0]}")
    done < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
    
    # Filter out models that don't match the current word
    local filtered_models=()
    for model in "${models[@]}"; do
      if [[ "$model" == *"$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done
    
    # Output completion matches to COMPREPLY array
    COMPREPLY=($(compgen -W "${filtered_models[*]}" -- "$cur"))
  else
    # Clear COMPREPLY when not providing model completions
    COMPREPLY=()
  fi
  
  # ALWAYS restore before ANY return/exit
  COMP_WORDBREAKS="$old_wb"
}

# Register the completion function
complete -F _ollama_run ollama run


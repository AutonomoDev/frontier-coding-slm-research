#!/bin/bash
# Bash completion script for the `ollama run` command

# Save original COMP_WORDBREAKS to restore later
local old_wb="$COMP_WORDBREAKS"

# Remove colon from COMP_WORDBREAKS to handle model names with colons
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

# Function to generate completions for ollama run
_ollama_run_completion() {
  # Get the current word being completed
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Find the index of "run" in the command words
  local run_index
  for i in "${!COMP_WORDS[@]}"; do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only trigger completion if we're at the correct position after "run"
  if [[ $COMP_CWORD -eq $((run_index + 1)) ]]; then

    # Get the list of available models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Filter the models based on the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

  else
    # Clear COMPREPLY if not completing after "run"
    COMPREPLY=()
  fi
}

# Register the completion function with bash
complete -F _ollama_run_completion ollama

# Restore the original COMP_WORDBREAKS
COMP_WORDBREAKS="$old_wb"


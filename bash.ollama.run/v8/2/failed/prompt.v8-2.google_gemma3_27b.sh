#!/bin/bash
# Bash completion script for the ollama run command

# Save the original COMP_WORDBREAKS value
local old_wb="$COMP_WORDBREAKS"

# Remove colons from COMP_WORDBREAKS to handle model names with colons
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

# Function to generate completion suggestions
_ollama_run_completion() {
  # Get current word, previous word, all words, and current word index
  _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
    # Manual fallback when helper unavailable
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  }

  # Find the index of 'run' in the command words array
  run_index=$(
    for i in "${!COMP_WORDS[@]}"; do
      if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
        echo "$i"
        break
      fi
    done
  )

  # Only trigger completion if we are at the correct position after 'run'
  if [[ "$COMP_CWORD" == "$((run_index + 1))" ]]; then
    # Get the list of available models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Filter models based on the current input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # If no models match, clear the completion list
    if [[ -z "${COMPREPLY[@]}" ]]; then
      COMPREPLY=()
    fi

  else
    # Clear completion list if not completing after 'run'
    COMPREPLY=()
  fi
}

# Register the completion function with bash
complete -F _ollama_run_completion ollama

# Restore the original COMP_WORDBREAKS value before exiting
COMP_WORDBREAKS="$old_wb"


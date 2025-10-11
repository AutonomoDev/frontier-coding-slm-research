#!/bin/bash
# Bash completion script for `ollama run` command

# Save original COMP_WORDBREAKS
local old_wb="$COMP_WORDBREAKS"
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

# Function to get completion words by reference
_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
    # Manual fallback when helper unavailable
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
}

# Completion function for `ollama run`
_ollama_run_completion() {
  # Find the index of "run" in the command words array
  run_index=-1
  for i in "${!COMP_WORDS[@]}"; do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only trigger completion if "run" is found and we're at the position after it
  if [[ $run_index -ge 0 && $COMP_CWORD -eq $((run_index + 1)) ]]; then
    # Get the list of models from `ollama list`
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Filter the models based on the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

  else
    # Clear COMPREPLY if not completing after "run"
    COMPREPLY=()
  fi
}

# Register the completion function
complete -F _ollama_run_completion ollama

# Restore original COMP_WORDBREAKS
COMP_WORDBREAKS="$old_wb"


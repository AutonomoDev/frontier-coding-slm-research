#!/bin/bash
# Source this file to enable ollama run completion.
#
# This script provides completion for the "ollama run" command.
# It retrieves a list of available models from "ollama list" and
# provides suggestions based on the user's input.

_ollama_run_completion() {
  local cur prev run_index old_wb
  local wordlist models

  # Find the index of the "run" word
  run_index=0
  for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only complete if the cursor is after the "run" word
  if [[ "$COMP_CWORD" -ne "$run_index" + 1 ]]; then
    return 0
  fi

  # Save the original COMP_WORDBREAKS
  old_wb=$COMP_WORDBREAKS

  # Remove ':' from COMP_WORDBREAKS to handle names like codellama:32b
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Get the list of models from "ollama list"
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Check if ollama list returned an error
  if [ $? -ne 0 ] || [ -z "$models" ]; then
    # Exit quietly if no models are found or if the command fails
    COMP_WORDBREAKS=$old_wb
    return 0
  fi

  # Create the wordlist for completion
  wordlist=$(echo "$models" | tr '\n' ' ')

  #Fallback for _get_comp_words_by_ref
  if ! type -t _get_comp_words_by_ref > /dev/null; then
    cur="${COMP_WORDS[$COMP_CWORD]}"
    prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  else
     cur=$( _get_comp_words_by_ref "$COMP_CWORD" )
     prev=$( _get_comp_words_by_ref "$((COMP_CWORD - 1))" )
  fi

  # Filter suggestions using compgen -W (safer than grep)
  COMPREPLY=($(compgen -W "$wordlist" -- "$cur"))

  # Remove duplicates from the suggestions
  COMPREPLY=($(echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

  # Restore COMP_WORDBREAKS
  COMP_WORDBREAKS=$old_wb

  return 0
}

# Register the completion function
complete -F _ollama_run_completion ollama

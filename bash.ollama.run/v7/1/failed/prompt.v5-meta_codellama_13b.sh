#!/bin/bash

_ollama_run_completion() {
  local cur prev old_wb models wordlist
  COMPREPLY=()

  # Get current and previous words.
  _get_comp_words_by_ref -n : cur prev

  # Get list of available local models from `ollama list`.
  if ! models=$(ollama list | awk 'NR>1 {print $1}'); then
    return 0
  fi

  # Restore original colon from COMP_WORDBREAKS.
  old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${old_wb//:}

  # Get list of available local models from `ollama list`.
  if ! models=$(ollama list | awk 'NR>1 {print $1}'); then
    return 0
  fi

  # Remove colon temporarily.
  old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${old_wb//:}

  # Deduplicate models and split into words.
  wordlist=$(echo "$models" | awk '!seen[$0]++' | tr ':' '\n')

  # If there are matches, add them to the list of completions.
  if [[ -n $wordlist ]]; then
    COMPREPLY=( $(compgen -W "$wordlist" -- "$cur") )
  fi

  # Restore original colon and exit.
  COMP_WORDBREAKS=$old_wb
}

# Register completion function with ollama command.
complete -F _ollama_run_completion ollama

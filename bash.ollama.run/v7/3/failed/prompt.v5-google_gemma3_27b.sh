#!/bin/bash
# This script provides Bash completion for the `ollama run` command.

_ollama_run_completion() {
  # Find the index of the "run" command.
  run_index=$(for i in "${!COMP_WORDS[@]}"; do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      echo "$i"
      break
    fi
  done)

  # Only activate completion if we're on the token immediately after "run".
  if [[ "$COMP_CWORD" -ne $((run_index + 1)) ]]; then
    return
  fi

  # Get the list of available models from `ollama list`.
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Check if ollama list returned anything.
  if [[ -z "$models" ]]; then
    return
  fi

  # Save the original COMP_WORDBREAKS.
  old_wb=$COMP_WORDBREAKS

  # Temporarily remove ":" from COMP_WORDBREAKS to allow completion of model names with colons.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:*}

  # Get the current word being typed.
  cur="${COMP_WORDS[$COMP_CWORD]}"
  prev="${COMP_WORDS[$COMP_CWORD-1]}"

  # Filter the model list based on the current word.
  wordlist=$(echo "$models" | grep "^$cur")

  # Restore the original COMP_WORDBREAKS.
  COMP_WORDBREAKS=$old_wb

  # Complete the words.
  compgen -W "$wordlist" -- "$cur"

  # Ensure the suggestions are unique
  COMPREPLY=( $(echo "$COMPREPLY[@]" | awk '!seen[$0]++') )
}

# Register the completion function.
complete -F _ollama_run_completion ollama


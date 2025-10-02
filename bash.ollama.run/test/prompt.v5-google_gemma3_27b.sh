#!/bin/bash
# This script provides bash completion for the `ollama run` command.

_ollama_run_completion() {
  # Standard completion variables
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  # --- Problem 1: The Trigger ---
  # We need a robust way to know we are completing an argument for 'run'.
  # Loop through all words before the cursor. If 'run' is one of them, we proceed.
  # This is superior to simple index checks, which fail when a colon splits a word.
  local in_run_context=false
  for (( i=0; i < COMP_CWORD; i++ )); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
      in_run_context=true
      break
    fi
  done

  if ! $in_run_context; then
    return
  fi

  # --- Problem 2: The Current Word (`cur`) ---
  # If the current word is empty and the character right before the cursor is a colon,
  # it means Bash split "model:" into "model" and "" (empty cur).
  # We must manually construct the correct prefix for `compgen` to use.
  if [[ -z "$cur" && "${COMP_LINE:COMP_POINT-1:1}" == ":" ]]; then
    cur="${prev}:"
  fi

  # Now, `cur` is correctly set to "model:" for the colon-completion case.

  # Save and modify COMP_WORDBREAKS. This is essential for `compgen` to treat
  # "llama3:8b" as a single word and match it against a prefix like "llama3:".
  local old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

  local models
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Restore COMP_WORDBREAKS as soon as we're done generating suggestions.
  # Do this in all exit paths.
  if [[ -z "$models" ]]; then
    COMP_WORDBREAKS=$old_wb
    return
  fi

  # Use `mapfile` to safely populate COMPREPLY from `compgen`'s output.
  # `compgen` will now correctly use our manually fixed `cur` variable.
  mapfile -t COMPREPLY < <(compgen -W "${models}" -- "${cur}")

  # Restore COMP_WORDBREAKS for safety.
  COMP_WORDBREAKS=$old_wb
}

# Register the completion function to be triggered for the `ollama` command.
complete -F _ollama_run_completion ollama
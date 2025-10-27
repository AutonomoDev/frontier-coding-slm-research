#!/bin/bash
# Bash completion for ollama run, handles colons in model names.

_ollama_completions() {
  # Check if the command is ollama run.  Early exit if not.
  if [[ ${COMP_WORDS[1]} != "run" ]]; then
    return
  fi

  # Save original COMP_WORDBREAKS
  local original_comp_wordbreaks="$COMP_WORDBREAKS"

  # Modify COMP_WORDBREAKS to handle colons
  COMP_WORDBREAKS=':'

  # Re-parse the command line words
  _get_comp_words_by_ref -n : cur prev

  # Restore original COMP_WORDBREAKS
  COMP_WORDBREAKS="$original_comp_wordbreaks"

  # Check if ollama is available
  if ! command -v ollama &>/dev/null; then
    return
  fi

  # Fetch the list of models
  local models=$(ollama list | awk 'NR>1 {print $1}')

  # Generate completion suggestions
  compgen -W "$models" -- "$cur" > /dev/fd/3  # Redirect to fd 3 to become COMPREPLY

  # Parse results from fd 3 into COMPREPLY
  COMPREPLY=( $(cat /dev/fd/3) )

  # Correctly display suggestions with colons
  __ltrim_colon_completions "$cur"

}

# Register the completion function
complete -F _ollama_completions ollama

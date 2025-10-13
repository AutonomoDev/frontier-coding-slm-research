#!/bin/bash

_ollama_run_completions() {
  local cur prev words IFS
  local original_wordbreaks

  # Save the original COMP_WORDBREAKS
  original_wordbreaks="$COMP_WORDBREAKS"

  # Temporarily remove ':' from COMP_WORDBREAKS to handle model names with colons
  COMP_WORDBREAKS=':'
  _get_comp_words_by_ref -n : cur prev
  COMP_WORDBREAKS="$original_wordbreaks"

  # Only activate for the 'ollama run' subcommand
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get the list of models from ollama list
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "$models" -- "${cur}") )
  fi
}

complete -F _ollama_run_completions ollama

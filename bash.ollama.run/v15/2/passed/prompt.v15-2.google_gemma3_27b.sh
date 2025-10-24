#!/bin/bash

_ollama_run_completions() {
  local cur prev words IFS
  local -a models

  # Handle model names with colons by temporarily modifying COMP_WORDBREAKS
  local original_wordbreaks="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=':'
  _get_comp_words_by_ref -n : cur prev
  COMP_WORDBREAKS="$original_wordbreaks"

  # Only activate for the 'ollama run' subcommand
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get the list of models from 'ollama list'
    models=($(ollama list | awk 'NR>1 {print $1}'))

    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "${models[@]}" -- "${cur}") )
  fi
}

complete -F _ollama_run_completions ollama
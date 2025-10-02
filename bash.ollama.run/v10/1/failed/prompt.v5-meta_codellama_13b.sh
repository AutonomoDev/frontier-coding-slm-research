#!/usr/bin/env bash

_ollama_completions() {
  # Only handle completions for 'run' subcommand
  [[ ${COMP_WORDS[1]} == "run" ]] || return

  # Handle colon in word breaks by temporarily removing it from COMP_WORDBREAKS
  local orig_wordbreaks="${COMP_WORDBREAKS//:/}"
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Re-parse current and previous words with -n : option
  _get_comp_words_by_ref -n : cur prev

  # Restore original COMP_WORDBREAKS immediately
  COMP_WORDBREAKS="$orig_wordbreaks"

  # Generate completions for 'run' subcommand by retrieving model names
  local models=$(ollama list | awk 'NR>1 {print $1}')
  compgen -W "$models" -- "$cur"
}

complete -F _ollama_completions ollama


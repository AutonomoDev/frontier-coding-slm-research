#!/bin/bash
# This is a Bash completion script for the `ollama` command.
# It provides completions for the `run` subcommand, specifically model names
# that are dynamically retrieved from the `ollama list` command.
# The script handles colons in model names correctly by removing them from
# the default word-breaking characters and using a helper function to re-parse
# the command line with our new rule. This ensures that completions work for models
# like "codellama:13b" without breaking due to Bash's default behavior on colons.

_ollama_completions() {
  # Save the original word break characters.
  local _old_wb=${COMP_WORDBREAKS}

  # Modify COMP_WORDBREAKS to remove the colon.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Use the helper to re-parse and correctly set `cur` and `prev`.
  # The `-n :` option tells it to NOT use the colon as a separator.
  _get_comp_words_by_ref -n : cur prev

  # Restore the original word breaks immediately to avoid side-effects.
  COMP_WORDBREAKS=${_old_wb}

  # If the previous word is "run", then we are completing a model name, so retrieve
  # the list of models dynamically and complete them using `compgen`.
  if [[ "$prev" == "run" ]]; then
    local models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi
}

# Register the completion function with the `complete` command.
complete -F _ollama_completions ollama

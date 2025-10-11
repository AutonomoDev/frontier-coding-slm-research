# [[HUMAN COMMENTED-OUT]]
#The following Bash script fulfills your requirements, with comments explaining each step.

#!/usr/bin/env bash

# This function handles advanced completion for 'ollama' command.
_ollama_completions() {
  local cur prev models
  # Save the original word break characters.
  local old_wb=${COMP_WORDBREAKS}
  # Modify COMP_WORDBREAKS to remove the colon.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
  # Use `_get_comp_words_by_ref` to correctly set `cur` and `prev`, with a colon as separator.
  _get_comp_words_by_ref -n : cur prev
  
  if [[ "${#COMP_WORDS[@]}" == "2" && "$prev" == "run" ]]; then
    # Fetch models dynamically by running `ollama list` command and extracting first column.
    local models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi
  
  # Restore the original word breaks immediately to avoid side-effects.
  COMP_WORDBREAKS=${old_wb}
}

complete -F _ollama_completions ollama

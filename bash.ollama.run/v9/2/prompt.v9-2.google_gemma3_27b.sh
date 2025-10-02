#!/bin/bash

# Bash completion script for `ollama run` command.
# Dynamically completes model names from `ollama list` output,
# handling model names with colons (e.g., codellama:13b).

_ollama_completions() {
  local cur prev
  local models

  # 1. Save the original word break characters.
  local _old_wb=${COMP_WORDBREAKS}
  # 2. Modify COMP_WORDBREAKS to remove the colon.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
  # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
  #    The `-n :` option tells it to NOT use the colon as a separator.
  _get_comp_words_by_ref -n : cur prev
  # 4. Restore the original word breaks immediately to avoid side-effects.
  COMP_WORDBREAKS=${_old_wb}

  # Check if we're completing after 'run'
  local i
  for ((i=1; i < COMP_CWORD; i++)); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
      # Get models list
      models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
      if [[ -n "$models" ]]; then
        # Use compgen directly without additional processing
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
      fi
      return
    fi
  done
}

# Register the completion with bash.
complete -F _ollama_completions ollama
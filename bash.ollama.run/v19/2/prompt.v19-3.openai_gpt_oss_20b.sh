#!/usr/bin/env bash

# Thinking...
# We need to produce a Bash completion script for "ollama run <model>". The requirements emphasize certain rules.
#
# We must output only Bash code, no markdown. We need to define a function _ollama_completions() and at end register with complete -F.
#
# We must incorporate comments but not too many, inline comments explaining critical sections.
#
# Edge cases: if ollama command not found, if no models output, etc.
#
# Let's craft:
#
# #!/usr/bin/env bash
# _ollama_completions() {
#   # Activate only for ollama run
#   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
#
#   local cur prev
#   # Get words, keep colon for model name prefixes
#   _get_comp_words_by_ref -n : cur prev
#
#   # Ensure ollama binary available
#   if ! command -v ollama &>/dev/null; then
#     COMPREPLY=(); return
#   fi
#
#   # Retrieve model names from ollama list, ignoring header
#   local models
#   models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#
#   # No models => nothing to complete
#   if [ -z "$models" ]; then
#     COMPREPLY=(); return
#   fi
#
#   # Generate completions using compgen
#   COMPREPLY=($(compgen -W "$models" -- "$cur"))
#
#   # Sort results alphabetically
#   COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#
#   # Trim colon prefix from completions if user typed a colon
#   __ltrim_colon_completions "$cur"
# }
#
# # Register completion function for ollama
# complete -F _ollama_completions ollama
#
# This should satisfy all constraints. Note: The requirement "Do NOT use if type checks, fallbacks, or manual loops." We did not use if type check. We used command -v check which is fine.
#
# Edge: the colon trimming: __ltrim_colon_completions "$cur" – but this is a builtin for bash completion that expects the current word, I think it's correct.
#
# Let's output this.
# ...done thinking.

_ollama_completions() {
  # Activate only when the user types: ollama run
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  # Get the current and previous words, keep ':' in the current word
  _get_comp_words_by_ref -n : cur prev

  # Bail out if the ollama binary is not available
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=(); return
  fi

  # Grab the list of models; ignore the header line
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  # No models found – nothing to complete
  if [ -z "$models" ]; then
    COMPREPLY=(); return
  fi

  # Generate candidate completions for the current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Alphabetically sort the completion candidates
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Remove the colon prefix from each completion if the user typed ':'
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

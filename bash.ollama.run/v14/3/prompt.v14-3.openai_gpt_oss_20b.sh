# Thinking...
# We need to output bash code only. Should include function _ollama_completions() with checks. Use _get_comp_words_by_ref -n : cur prev to avoid splitting colon. If fails maybe fallback. Then run ollama list, parse lines skipping header, extract first column. Build array models. Use compgen -W "${models[*]}" -- "$cur". Then __ltrim_colon_completions "$cur". Register completion. Provide inline comments.

# Edge: If command not found, just return.

# Also, should handle no models: return.

# Need to ensure variable naming. Use local array.

# Also handle environment where COMP_WORDS length < 2? But check.

# Implementation:

# ```bash
# _ollama_completions() {
#   local cur prev
#   # Check for command and subcommand
#   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

#   # Avoid splitting on ':' by not using default word splitting
#   if _get_comp_words_by_ref -n : cur prev; then
#     :
#   else
#     # Fallback: manually assign cur and prev
#     cur="${COMP_WORDS[COMP_CWORD]}"
#     prev="${COMP_WORDS[COMP_CWORD-1]}"
#   fi

#   # Ensure ollama binary exists
#   command -v ollama &>/dev/null || { COMPREPLY=(); return; }

#   # Get list of models
#   local models=()
#   while IFS= read -r line; do
#     # Skip header
#     [[ "$line" == NAME* ]] && continue
#     # Get first word (model name)
#     models+=("${line%%[[:space:]]*}")
#   done < <(ollama list 2>/dev/null)

#   # If no models, exit
#   [[ ${#models[@]} -eq 0 ]] && { COMPREPLY=(); return; }

#   # Generate completions
#   COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
#   __ltrim_colon_completions "$cur"
# }
# complete -F _ollama_completions ollama
# ```

# But need to check that _get_comp_words_by_ref is part of bash completion. It's part of bash-completion library. Should use it. Also maybe need to add -n ':' option. This is correct. Provide inline comments.

# Add 'local' before variables. Ensure quoting.

# Also we need to handle case where cur may be empty. compgen will handle.

# Make sure compgen is used correctly: compgen -W "$modellist" -- "$cur". The list is a string. Use array? It's okay.

# Better to use `compgen -W "${models[*]}" -- "$cur"`. That passes space-separated.

# Edge: model names contain colon; should be fine.

# Add comment about skipping header.

# Add comment about __ltrim_colon_completions.

# Return after completions.

# Let's produce final code.
# ...done thinking.

_ollama_completions() {
  local cur prev
  # Only activate for "ollama run" command
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Avoid Bash splitting on ':' by using _get_comp_words_by_ref with -n :
  if _get_comp_words_by_ref -n : cur prev; then
    :  # success, cur and prev are set
  else
    # Fallback: assign directly (rare case when completion library not loaded)
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Ensure ollama binary is available
  command -v ollama &>/dev/null || { COMPREPLY=(); return; }

  # Collect available model names from "ollama list"
  local models=()
  while IFS= read -r line; do
    # Skip the header line
    [[ "$line" == NAME* ]] && continue
    # Grab the first column (model name)
    models+=("${line%%[[:space:]]*}")
  done < <(ollama list 2>/dev/null)

  # No models found – nothing to complete
  [[ ${#models[@]} -eq 0 ]] && { COMPREPLY=(); return; }

  # Generate completion list matching the current prefix
  COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

  # Trim any leading colon from the completion results
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the "ollama" command
complete -F _ollama_completions ollama

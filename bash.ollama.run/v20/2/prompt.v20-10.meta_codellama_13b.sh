# Bash Completion Generator — `ollama run <model>`

_ollama_completions() {
  # Validate command
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

  # Extract word info
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models
  if ! command -v ollama &>/dev/null; then return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && return

  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort + trim
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

#[[HUMAN COMMENTED-OUT]]
#Note: This script assumes that the `ollama` command is available in the current PATH, and that it returns a list of models in the format `<model> <description>` on the standard output. The generated completions are sorted alphabetically and trimmed to remove the leading colon.

_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev # Variables for colon handling

  # Handle colons
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama is installed
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  # Get the list of available models
  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  # If no models are available, exit
  if [ -z "$models" ]; then
    COMPREPLY=();
    return
  fi

  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort the completions
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Trim colon prefixes from completions
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

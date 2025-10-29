_ollama_completions() {
  # Check if the command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Extract the current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models from ollama list
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions based on the current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort completions and trim colons
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama



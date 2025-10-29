_ollama_completions() {
  # Validate command: ensure we are completing after 'ollama run'
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Extract word info: get current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models: list available models using ollama
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions: use compgen to filter models based on current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort + trim: sort completions and remove leading colons
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama


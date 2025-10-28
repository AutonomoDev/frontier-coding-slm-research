```bash
_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Get current and previous words, handling colons
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama is available
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=()
    return
  fi

  # Parse models into scalar string (not array)
  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  if [ -z "$models" ]; then
    COMPREPLY=()
    return
  fi

  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort completions
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Trim colon prefix from completions
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


```bash
_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev # Get the current word with the colon prefix

  # Check if ollama is installed
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  # Parse models from ollama list
  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

  # Handle case where no models are found
  if [ -z "$models" ]; then
    COMPREPLY=();
    return
  fi

  # Generate completions based on the models
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort the completions alphabetically
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Trim colon prefixes from completions
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

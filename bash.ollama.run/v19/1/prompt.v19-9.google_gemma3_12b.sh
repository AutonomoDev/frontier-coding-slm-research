```bash
# Bash completion for ollama run

_ollama_completions() {
  local cur prev
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Get the current word being completed
  _get_comp_words_by_ref -n : cur prev

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

  # Generate completions for the current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort the completions alphabetically
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Fix colons: trim the prefix from completed words.
  __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
```


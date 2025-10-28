```bash
_ollama_completions() {
  # Check if this completion is for `ollama run`
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
  # Only complete the model argument (third word)
  [[ $COMP_CWORD -ne 2 ]] && return 0;

  # Handle colon-separated words
  local cur prev
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Fetch models from ollama list, skip header
  local models=()
  if command -v ollama &>/dev/null; then
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  fi

  # Sort models for consistent ordering
  IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

  # Generate completions
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

  # Trim colons if supported
  if type __ltrim_colon_completions &>/dev/null; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register completion
complete -F _ollama_completions ollama
```


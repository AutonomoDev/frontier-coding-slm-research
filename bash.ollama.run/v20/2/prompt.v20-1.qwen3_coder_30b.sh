```bash
_ollama_completions() {
  # Validate that the command is 'ollama run'
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Extract current and previous words for completion
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Check if ollama is installed
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

  # Fetch list of models, skip header line and extract first column (model name)
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions based on current input
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort completions alphabetically
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

  # Trim colons from the beginning of completions if needed
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


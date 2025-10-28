```bash
_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev # Set cur to the word before the cursor, including colon if present

  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Parse models from ollama list
  if [ -z "$models" ]; then
    COMPREPLY=();
    return
  fi

  COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions

  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions

  __ltrim_colon_completions "$cur" # Trim colon prefix from completions
}

complete -F _ollama_completions ollama
```


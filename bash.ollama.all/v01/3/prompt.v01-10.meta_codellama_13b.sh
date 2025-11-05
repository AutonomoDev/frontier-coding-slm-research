```bash
_ollama_completions() {
  # Validate command (only ollama subcommands)
  [[ "${COMP_WORDS[0]}" != "ollama" || ! "$(type -t _$(echo ${COMP_WORDS[@]:1} | tr '[:upper:]' '[:lower:]'))" ]] && { COMPREPLY=(); return; }
  
  # Extract word info and fetch models
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  local models
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  
  # Generate completions
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  
  # Sort + trim
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


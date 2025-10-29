_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev # Set cur to the current word with colon prefix

  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Parse ollama list output
  if [ -z "$models" ]; then
    COMPREPLY=();
    return
  fi

  COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions based on models

  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions alphabetically

  __ltrim_colon_completions "$cur" # Trim colon prefix from completions

}

complete -F _ollama_completions ollama

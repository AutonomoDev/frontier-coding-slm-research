_ollama_completions() {
  # Validate command.
  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "serve" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "create" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "show" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "stop" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "pull" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "push" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signin" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signout" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "list" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "ps" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "cp" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "rm" ]] &&
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "help" ]]; then
    COMPREPLY=(); return;
  fi

  # Extract word info.
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models.
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions.
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort + trim.
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

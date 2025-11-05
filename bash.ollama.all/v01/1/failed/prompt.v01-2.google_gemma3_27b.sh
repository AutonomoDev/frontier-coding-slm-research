_ollama_completions() {
  # Validate command for serve
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "serve" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for create
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "create" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for show
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "show" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for run
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for stop
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "stop" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for pull
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "pull" ]] && { COMPREPLY=(); return; }

  # Validate command for push
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "push" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for signin
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signin" ]] && { COMPREPLY=(); return; }

  # Validate command for signout
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signout" ]] && { COMPREPLY=(); return; }

  # Validate command for list
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "list" ]] && { COMPREPLY=(); return; }

  # Validate command for ps
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "ps" ]] && { COMPREPLY=(); return; }

  # Validate command for cp
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "cp" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for rm
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "rm" ]] && { COMPREPLY=(); return; }
  _get_comp_words_by_ref -n : cur prev
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command for help
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "help" ]] && { COMPREPLY=(); return; }
}

complete -F _ollama_completions ollama

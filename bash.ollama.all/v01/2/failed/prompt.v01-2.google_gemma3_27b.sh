_ollama_completions() {
  # Validate command - serve
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

  # Validate command - create
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "create" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
  
  # Validate command - show
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "show" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command - run
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command - stop
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "stop" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command - pull
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "pull" ]] && { COMPREPLY=(); return; }

  # Validate command - push
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "push" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
  
  # Validate command - cp
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "cp" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command - rm
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "rm" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"

  # Validate command - list
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "list" ]] && { COMPREPLY=(); return; }

  # Validate command - ps
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "ps" ]] && { COMPREPLY=(); return; }
  
  # Validate command - signin/signout/help
  [[ "${COMP_WORDS[0]}" != "ollama" ]] && { COMPREPLY=(); return; }
  
  
}

complete -F _ollama_completions ollama
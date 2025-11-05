_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "pull" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signin" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "signout" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "list" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "ps" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
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
}

_ollama_completions() {
  # Check if the command is "ollama" and the subcommand matches
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "help" ]] && { COMPREPLY=(); return; }
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama



_ollama_completions() {
  local cur prev words cword split
  _get_comp_words_by_ref -n : cur prev words cword

  case "${words[1]}" in
    show|run|stop|push|cp|rm)
      _get_model_completions
      ;;
    pull|start|signin|signout|list|ls|ps|help)
      COMPREPLY=()
      ;;
    create)
      local flags=(--file -f --quantize -q)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "${flags[*]}" -- "$cur"))
      else
        _get_model_completions
      fi
      ;;
    serve|serve)
      COMPREPLY=()
      ;;
    esac
}

_get_model_completions() {
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  if [[ "${words[1]}" == "stop" ]]; then
    models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
  else
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  fi
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
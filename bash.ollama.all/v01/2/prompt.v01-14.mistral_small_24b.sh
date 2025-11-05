_ollama_completions() {
  # Validate command
  [[ "${COMP_WORDS[0]}" != "ollama" || -z "${COMP_WORDS[1]}" ]] && { COMPREPLY=(); return; }

  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions for serve, create, show, run, stop, pull, push, signin, signout, list, ps, cp, rm
  case "${COMP_WORDS[1]}" in
    serve)
      COMPREPLY=()
      ;;
    create)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--file --quantize" -- "$cur"))
      else
        COMPREPLY=()
      fi
      ;;
    show|run|stop|push|cop|rm)
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      ;;
    pull|signin|signout|list|ps)
      COMPREPLY=()
      ;;
    cp)
      if [[ "${COMP_WORDS[2]}" == -* ]]; then
        COMPREPLY=()
      else
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
      fi
      ;;
    help)
      COMPREPLY=()
      ;;
  esac

  # Sort + trim
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

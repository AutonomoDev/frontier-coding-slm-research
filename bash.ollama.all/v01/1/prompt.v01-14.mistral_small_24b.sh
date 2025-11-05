```bash
_ollama_completions() {
  # Validate command
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" == "" ]] && { COMPREPLY=(); return; }

  # Extract word info
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Fetch models
  if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions for subcommands
  case "${COMP_WORDS[1]}" in
    serve)
      COMPREPLY=()
      ;;
    create)
      if [[ ${cur} == -* ]]; then
        COMPREPLY=(--file --quantize)
      else
        COMPREPLY=$(compgen -W "IMAGE_FILE Modefile" -- "$cur")
      fi
      ;;
    show|run|stop|push|cp|rm)
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      ;;
    pull|signin|signout|list|ps|help)
      COMPREPLY=()
      ;;
  esac

  # Sort + trim
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```


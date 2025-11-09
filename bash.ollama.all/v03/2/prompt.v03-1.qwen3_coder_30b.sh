```bash
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: show all commands if previous word is 'ollama'
  if [[ "$prev" == "ollama" ]]; then
    COMPREPLY=($(compgen -W "show run stop push cp rm create pull signin signout list ls ps serve start help" -- "$cur"))
    return
  fi

  # Get current command (subcommand)
  local cmd=""
  for ((i=1; i < COMP_CWORD; i++)); do
    if [[ "${COMP_WORDS[i]}" != -* ]]; then
      cmd="${COMP_WORDS[i]}"
      break
    fi
  done

  case "$cmd" in
    show|run|stop|push|cp|rm)
      # Step A: Extract word info
      local cur prev
      _get_comp_words_by_ref -n : cur prev

      # Step B: Fetch models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Step C: Generate completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Step D: Sort and trim
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      # Special flags for create
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      else
        # Model name completion
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    pull)
      # Special flags for pull
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
      else
        # Model name completion
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    run)
      # Special flags for run
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
      else
        # Model name completion
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    show)
      # Special flags for show
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
      else
        # Model name completion
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    stop)
      # Use 'ollama ps' to get running models
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      # No argument completion
      COMPREPLY=()
      ;;
  esac
}

complete -F _ollama_completions ollama
```


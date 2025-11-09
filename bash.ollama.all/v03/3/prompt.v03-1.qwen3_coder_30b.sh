```bash
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: show all subcommands if no prior word or ollama itself
  if [[ $prev == "ollama" ]] || [[ $COMP_CWORD -eq 1 ]]; then
    local commands="create pull push cp rm run show stop serve start list ls ps signin signout help"
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    return
  fi

  # Get current command (the word after ollama)
  local cmd="${COMP_WORDS[1]}"

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
      # Special flag completion for create
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
      # Special flag completion for pull
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
      # Special flag completion for run
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
      # Special flag completion for show
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
      # Stop command needs ps output for model names
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
    serve|start|list|ls|ps|signin|signout|help)
      # No argument completion
      COMPREPLY=()
      ;;
  esac
}

complete -F _ollama_completions ollama
```


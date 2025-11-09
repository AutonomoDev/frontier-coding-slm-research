```bash
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: list subcommands
  case "$cur" in
    ollama)
      COMPREPLY=($(compgen -W "create pull run show stop push cp rm serve start pull signin signout list ls ps help" -- "$cur"))
      ;;

    create) # Flags: --file, -f, --quantize, -q
      case "$prev" in
        create)
          COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
          ;;
        *)
          ;;
      esac
      ;;

    pull) # Flags: --insecure
      case "$prev" in
        pull)
          COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
          ;;
        *)
          ;;
      esac
      ;;

    run) # Flags: --format, --hidethinking, --insecure, --keepalive, --nowordwrap, --think, --verbose
      case "$prev" in
        run)
          COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
          ;;
        *)
          # Model name completion
          local models
          if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
          models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
          [[ -z "$models" ]] && { COMPREPLY=(); return; }
          COMPREPLY=($(compgen -W "$models" -- "$cur"))
          COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
          __ltrim_colon_completions "$cur"
          ;;
      esac
      ;;

    show) # Flags: --license, --modefile, --parameters, --system, --template, --verbose
      case "$prev" in
        show)
          COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
          ;;
        *)
          # Model name completion
          local models
          if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
          models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
          [[ -z "$models" ]] && { COMPREPLY=(); return; }
          COMPREPLY=($(compgen -W "$models" -- "$cur"))
          COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
          __ltrim_colon_completions "$cur"
          ;;
      esac
      ;;

    stop) # Requires `ollama ps` for model names
      if [[ "$prev" == "stop" ]]; then
        local models
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      else
        COMPREPLY=()
      fi
      ;;

    push) # Model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;

    cp) # Model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;

    rm) # Model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;

    serve)
      ;;

    start)
      ;;

    signin)
      ;;

    signout)
      ;;

    list)
      ;;

    ls)
      ;;

    ps)
      ;;

    help)
      ;;

    *)
      ;;
  esac
}

complete -F _ollama_completions ollama
```


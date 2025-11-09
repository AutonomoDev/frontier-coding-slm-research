```bash
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  case "$cur" in
    ollama)
      COMPREPLY=($(compgen -W "create pull run show list ls ps serve start signin signout signin signout push cp rm help" -- "$cur"))
      ;;
    create)
      COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      ;;
    pull)
      COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
      ;;
    run)
      COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
      ;;
    show)
      COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
      ;;
    show|run|stop|push|cp|rm)
      # Step A: Extract Word Info
      local cur prev
      _get_comp_words_by_ref -n : cur prev

      # Step B: Fetch Models (Handle missing `ollama` command and empty model list)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Step C: Generate Completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Step D: Sort and Trim
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    stop)
      # For 'stop', we need to list running models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    *)
      ;;
  esac
}

complete -F _ollama_completions ollama
```


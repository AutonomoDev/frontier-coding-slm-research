```bash
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  case "$cur" in
    ollama)
      # Top-level completion: list all subcommands
      COMPREPLY=($(compgen -W "create pull run show stop push cp rm serve start pull signin signout list ls ps help" -- "$cur"))
      ;;
    create)
      # Completion for create command with flags
      COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      ;;
    pull)
      # Completion for pull command with flags
      COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
      ;;
    run)
      # Completion for run command with flags
      COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
      ;;
    show)
      # Completion for show command with flags
      COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
      ;;
    stop)
      # Completion for stop command. Requires fetching models.
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Step A: Extract Word Info
      local cur prev
      _get_comp_words_by_ref -n : cur prev

      # Step C: Generate Completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Step D: Sort and Trim
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    *)
      # Completion for commands requiring model name
      if [[ "$cur" == "run" || "$cur" == "show" || "$cur" == "stop" || "$cur" == "push" || "$cur" == "cp" || "$cur" == "rm" ]]; then
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
      fi
      ;;
  esac
}

complete -F _ollama_completions ollama
```


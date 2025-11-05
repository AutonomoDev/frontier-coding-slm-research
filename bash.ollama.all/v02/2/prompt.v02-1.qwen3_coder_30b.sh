_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: show all subcommands if previous word is 'ollama'
  if [[ "$prev" == "ollama" ]]; then
    COMPREPLY=(
      show run stop push cp rm serve pull signin signout list ps help create
    )
    return
  fi

  # Determine subcommand from current word
  local subcmd="$prev"

  case "$subcmd" in
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
      # Special flag completion for create command
      if [[ "$cur" == -* ]]; then
        COMPREPLY=(
          --file -f --quantize -q
        )
      fi
      ;;
    serve|pull|signin|signout|list|ps|help)
      # No argument completion needed
      COMPREPLY=()
      ;;
  esac
}

complete -F _ollama_completions ollama

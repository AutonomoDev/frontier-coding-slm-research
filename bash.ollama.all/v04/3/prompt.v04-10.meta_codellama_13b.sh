_ollama_completions() {
  # Get the current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Switch on the subcommand
  case "${prev}" in
    show|run)
      # Extract models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Generate completion set
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Sort and trim
      __ltrim_colon_completions "$cur"
      ;;
    stop)
      # Extract models (from `ollama ps` instead of `ollama list`)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Generate completion set
      COMPREPLY=($(compgen -W "$models" -- "$cur"))

      # Sort and trim
      __ltrim_colon_completions "$cur"
      ;;
    create)
      # Extract models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Generate completion set (model first, then flags)
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      local flags
      flags=(--file -f --quantize -q)
      [[ "${prev}" == "create" ]] && { COMPREPLY+=( $(compgen -W "${flags[@]}" -- "$cur") ); }

      # Sort and trim
      __ltrim_colon_completions "$cur"
      ;;
    pull|push)
      # No model completion (just flags)
      local flags
      flags=(--insecure)
      [[ "${prev}" == "pull" ]] && { COMPREPLY+=( $(compgen -W "${flags[@]}" -- "$cur") ); }
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      # No completion (empty set)
      COMPREPLY=()
      ;;
  esac
}
complete -F _ollama_completions ollama
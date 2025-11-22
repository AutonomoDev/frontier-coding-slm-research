_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Get the current and previous words

  if [[ "$cur" == "ollama" ]]; then
    COMPREPLY=(show run stop push cp rm create pull serve start list ls ps signin signout help) # Complete with all commands
    return
  fi

  case "$prev" in
    show|run|stop|push|cp|rm) # Commands requiring <MODEL> completion
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi # Check if ollama command exists
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Fetch model list
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Handle empty model list
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    create)
      COMPREPLY=(--file -f --quantize -q) # Flags for create
      ;;
    pull)
      COMPREPLY=(--insecure) # Flags for pull
      ;;
    run)
      COMPREPLY=(--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose) # Flags for run
      ;;
    show)
      COMPREPLY=(--license --modefile --parameters --system --template --verbose) # Flags for show
      ;;
    stop)
      local models
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    serve|start|list|ls|ps|signin|signout|help)
      : # No argument completion needed
      ;;
    *)
      : # Ignore other cases
      ;;
  esac
}

complete -F _ollama_completions ollama # Register the completion function

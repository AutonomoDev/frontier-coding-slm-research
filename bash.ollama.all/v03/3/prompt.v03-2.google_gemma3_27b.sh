_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Get current and previous words

  case "$prev" in
    ollama)
      COMPREPLY=(show run stop push cp rm create pull serve start list ls ps help signin signout) # Top-level completion
      ;;
    show|run|stop|push|cp|rm) # Commands requiring model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi # Check if ollama command exists
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Fetch model list
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Handle empty model list
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim colon completions
      ;;
    create)
      COMPREPLY=(--file -f --quantize -q)
      ;;
    pull)
      COMPREPLY=(--insecure)
      ;;
    run)
      COMPREPLY=(--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose)
      ;;
    show)
      COMPREPLY=(--license --modefile --parameters --system --template --verbose)
      ;;
    stop) # Stop command, complete with running models
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    serve|start|list|ls|ps|help|signin|signout)
      : # No completion needed for these commands
      ;;
    *)
      : # Do nothing for unknown commands
      ;;
  esac
}
complete -F _ollama_completions ollama



_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Extract current and previous words

  case "$cur" in
    ollama) # Top-level completion - list subcommands
      COMPREPLY=(show run stop push cp rm create serve pull signin signout list ps help)
      ;;
    show|run|stop|push|cp|rm) # Commands requiring model name completion
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi # Check if ollama is installed
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Fetch model names
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Handle empty model list
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    create) # Completion for create flags
      COMPREPLY=(--file -f --quantize -q)
      ;;
    serve|pull|signin|signout|list|ps|help) # Commands with no argument completion
      : # Do nothing - no completion needed
      ;;
    *)
      : # Unknown command - do nothing
      ;;
  esac
}

complete -F _ollama_completions ollama # Register the completion function

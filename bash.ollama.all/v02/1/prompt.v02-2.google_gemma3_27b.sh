_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Get current and previous words

  case "$cur" in
    ollama)
      COMPREPLY=(show run stop push cp rm create serve pull signin signout list ps help) # Top-level completion
      ;;
    show|run|stop|push|cp|rm) # Commands requiring <MODEL> completion
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi # Check if ollama is installed
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Get list of models
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Handle empty model list
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    create)
      COMPREPLY=(--file -f --quantize -q) # Complete create flags
      ;;
    serve|pull|signin|signout|list|ps|help)
      # Commands with no argument completion
      ;;
    *)
      ;;
  esac
}

complete -F _ollama_completions ollama

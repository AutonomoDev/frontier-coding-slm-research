_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Extract current and previous words

  case "$prev" in
    ollama) # Top-level completion: list subcommands
      COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
      ;;
    show|run|stop|push|cp|rm) # Model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi # Check if ollama is installed
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Get model names
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Return if no models found
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    create) # Create command with flag completion
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      fi
      ;;
    serve|pull|signin|signout|list|ps|help) # Commands with no argument completion
      COMPREPLY=()
      ;;
    *) # No completion
      COMPREPLY=()
      ;;
  esac

  # Handle argument completion for specific flags
  case "$prev" in
    -f|--file)
        _filedir
        return
      ;;
    -q|--quantize)
        COMPREPLY=($(compgen -W "q2_K q3_K_M q3_K_S q4_0 q4_K_M q4_K_S q5_K_M q5_K_S q8_0" -- "$cur"))
        return
      ;;
  esac

}

complete -F _ollama_completions ollama

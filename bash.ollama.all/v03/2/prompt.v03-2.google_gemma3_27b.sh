_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Extract current and previous words

  case "$prev" in
    ollama) # Top-level completion: list subcommands
      COMPREPLY=(show run stop push cp rm create pull serve start list ls ps signin signout help)
      ;;
    show|run|stop|push|cp|rm) # Commands requiring model name completion
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') # Fetch model list
      [[ -z "$models" ]] && { COMPREPLY=(); return; } # Handle empty model list
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    create) # Flags for create
      local flags="--file -f --quantize -q"
      COMPREPLY=( $flags )
      ;;
    pull) # Flags for pull
      local flags="--insecure"
      COMPREPLY=( $flags )
      ;;
    run) # Flags for run
      local flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
      COMPREPLY=( $flags )
      ;;
    show) # Flags for show
      local flags="--license --modefile --parameters --system --template --verbose"
      COMPREPLY=( $flags )
      ;;
    stop) # Models for stop command
      local models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate completions
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) # Sort completions
      __ltrim_colon_completions "$cur" # Trim leading colons
      ;;
    serve|start|list|ls|ps|signin|signout|help) # Commands with no argument completion
      ;;
    *)
      ;;
  esac
}

complete -F _ollama_completions ollama



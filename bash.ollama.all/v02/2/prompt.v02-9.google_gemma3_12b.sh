# Bash completion function for ollama
_ollama_completions() {
  # Get current and previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Top-level completion: list subcommands
  case "$cur" in
    ollama)
      COMPREPLY=($(compgen -W "create pull push run show stop cp rm serve pull signin signout list ps help" -- "$cur"))
      ;;

    create)
      # Completion for create command flags
      COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      ;;

    *)
      # Completion for commands requiring model names
      if [[ "$cur" == "show" || "$cur" == "run" || "$cur" == "stop" || "$cur" == "push" || "$cur" == "cp" || "$cur" == "rm" ]]; then
        # Step A: Extract word info (already done by _get_comp_words_by_ref)

        # Step B: Fetch models.  Handle missing command and empty model list
        if ! command -v ollama &>/dev/null; then
          COMPREPLY=();
          return;
        fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }

        # Step C: Generate completions
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Step D: Sort and trim
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
  esac
}

# Register the completion function
complete -F _ollama_completions ollama

```bash
# Bash completion function for ollama
_ollama_completions() {
  # Get previous words
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Handle top-level completion (ollama)
  if [[ "$cur" == "ollama" ]]; then
    COMPREPLY=($(compgen -W "create run show stop push cp rm serve pull signin signout list ps help" -- "$cur"))
    return
  fi

  # Handle commands requiring model names
  case "$cur" in
      run|show|stop|push|cp|rm)
        # Step A: Extract word info (already done with _get_comp_words_by_ref)

        # Step B: Fetch models (handle missing ollama command and empty model list)
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }

        # Step C: Generate completions
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Step D: Sort and Trim
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        ;;

      create)
        # Handle create command with flag completion
        COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
        ;;

      *)
        # Handle commands with no argument completion
        COMPREPLY=($(compgen -W "serve pull signin signout list ps help" -- "$cur"))
        ;;
  esac
}

# Register the completion function
complete -F _ollama_completions ollama
```


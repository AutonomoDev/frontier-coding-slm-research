# Bash completion function for ollama
_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev # Extract word info

  case "$cur" in
    ollama)
      # Provide completion for top-level subcommands
      COMPREPLY=($(compgen -W "create pull serve run list show push cp rm signin signout ps help" -- "$cur"))
      ;;

    create)
      # Completion for flags: --file, -f, --quantize, -q
      COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
      ;;

    *)
      # Completion for commands requiring <MODEL>
      if [[ "$cur" == "show" || "$cur" == "run" || "$cur" == "stop" || "$cur" == "push" || "$cur" == "cp" || "$cur" == "rm" ]]; then

        # Fetch models and provide completion
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }

        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"

      else
        # Completion for commands with no argument completion
        if [[ "$cur" == "serve" || "$cur" == "pull" || "$cur" == "signin" || "$cur" == "signout" || "$cur" == "list" || "$cur" == "ps" || "$cur" == "help" ]]; then
          COMPREPLY=() # No completion
        fi
      fi
      ;;
  esac
}

# Register the completion function
complete -F _ollama_completions ollama

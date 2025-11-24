_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev words cword
  local subcommand="${words[1]}"

  case "$subcommand" in
    show|run|stop|push|cp|rm)
      if [[ "$subcommand" == "stop" ]]; then
        local models
        models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      else
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    create)
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    pull)
      COMPREPLY=()
      ;;
    run)
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      COMPREPLY=()
      ;;
    *)
      COMPREPLY=("${subcommand}")
      ;;
  esac
}

complete -F _ollama_completions ollama
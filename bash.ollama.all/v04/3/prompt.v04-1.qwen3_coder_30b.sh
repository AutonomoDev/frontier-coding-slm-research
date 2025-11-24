_ollama_completions() {
  _get_comp_words_by_ref -n : cur prev words cword
  local subcommand="${words[1]}"
  case "$subcommand" in
    show|run|stop|push|cp|rm)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      if [[ "$subcommand" == "stop" ]]; then
        models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      else
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      fi
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      return
      ;;
    create|pull|run|show)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if [[ "$cur" == -* ]]; then
        case "$subcommand" in
          create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            ;;
          pull)
            COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            ;;
          run)
            COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
            ;;
          show)
            COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
            ;;
        esac
        return
      fi
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      if [[ "$subcommand" == "stop" ]]; then
        models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      else
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      fi
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      return
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      COMPREPLY=()
      return
      ;;
    *)
      COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
      return
      ;;
  esac
}
complete -F _ollama_completions ollama
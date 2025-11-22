_ollama_completions() {
  _get_comp_words_by_ref -n : cur prev words cword
  local subcommand="${words[1]}"
  case "${subcommand}" in
    show|run|stop|push|cp|rm)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      if [[ "${subcommand}" == "stop" ]]; then
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
      if [[ "${subcommand}" == "pull" ]]; then
        COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
        return
      elif [[ "${subcommand}" == "create" ]]; then
        if [[ "$cur" == -* ]]; then
          COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
          return
        fi
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        return
      elif [[ "${subcommand}" == "run" ]]; then
        if [[ "$cur" == -* ]]; then
          COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
          return
        fi
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        return
      elif [[ "${subcommand}" == "show" ]]; then
        if [[ "$cur" == -* ]]; then
          COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
          return
        fi
        if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
        return
      fi
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      COMPREPLY=()
      return
      ;;
    *)
      # Top-level completion
      COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
      return
      ;;
  esac
}
complete -F _ollama_completions ollama


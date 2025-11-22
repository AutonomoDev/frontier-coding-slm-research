_ollama_completions() {
  _get_comp_words_by_ref -n : cur prev words cword
  local subcommand="${words[1]}"

  case "$subcommand" in
    show)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=(--license --modefile --parameters --system --template --verbose)
      else
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    run)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=(--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose)
      else
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    stop)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      local models
      models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    push)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    cp)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    rm)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=(--file --quantize)
      else
        local cur prev
        _get_comp_words_by_ref -n : cur prev
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        [[ -z "$models" ]] && { COMPREPLY=(); return; }
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
      fi
      ;;
    pull)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=(--insecure)
      else
        COMPREPLY=()
      fi
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      COMPREPLY=()
      ;;
    *)
      COMPREPLY=(show run stop push cp rm create pull serve start signin signout list ls ps help)
      ;;
  esac
}

complete -F _ollama_completions ollama


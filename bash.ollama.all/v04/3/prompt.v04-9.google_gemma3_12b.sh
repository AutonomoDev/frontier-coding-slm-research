_ollama_completions() {
  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  case "$words[1]" in
    show)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    run)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    stop)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
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
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
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
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
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
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      local cur prev
      _get_comp_words_by_ref -n : cur prev
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
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
    serve)
      COMPREPLY=()
      ;;
    start)
      COMPREPLY=()
      ;;
    signin)
      COMPREPLY=()
      ;;
    signout)
      COMPREPLY=()
      ;;
    list)
      COMPREPLY=()
      ;;
    ls)
      COMPREPLY=()
      ;;
    ps)
      COMPREPLY=()
      ;;
    help)
      COMPREPLY=()
      ;;
    *)
      COMPREPLY=("ollama show")
      ;;
  esac
}

complete -F _ollama_completions ollama



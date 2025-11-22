
_ollama_completions() {
  local cur prev cword words subcommand
  _get_comp_words_by_ref -n : cur prev words cword

  subcommand=${words[1]}
  case "$subcommand" in
    show | run | stop)
      if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
      fi

      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    push | cp | rm)
      _model_completions
      ;;
    create)
      if [[ $cword -eq 1 ]]; then
        COMPREPLY=()
        return
      fi

      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    pull)
      if [[ $cword -eq 1 ]]; then
        COMPREPLY=()
        return
      fi

      local flags="--insecure"
      COMPREPLY=($(compgen -W "$flags" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    serve | start | signin | signout | list | ls | ps)
      COMPREPLY=()
      return
      ;;
  esac
}
complete -F _ollama_completions ollama


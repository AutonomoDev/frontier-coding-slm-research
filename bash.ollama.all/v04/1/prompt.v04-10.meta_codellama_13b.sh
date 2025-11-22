```bash
_ollama_completions() {
  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  case "${words[1]}" in
    show|run|stop)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    push|cp|rm)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    pull)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local flags
      flags="--insecure"
      COMPREPLY=($(compgen -W "$flags" -- "$cur"))
      ;;
    run)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    show)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    serve|start|signin|signout|list|ls|ps|help)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local flags
      flags="--license --modefile --parameters --system --template --verbose"
      COMPREPLY=($(compgen -W "$flags" -- "$cur"))
      ;;
    *)
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local subcommands
      subcommands="show run stop push cp rm create pull serve start signin signout list ls ps help"
      COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
      __ltrim_colon_completions "$cur"
  esac
}
complete -F _ollama_completions ollama
```


```bash
#!/bin/bash

_ollama_completions() {
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  case "$prev" in
    show|run|stop|push|cp|rm)
      # Fetch models
      if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
      local models
      models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      [[ -z "$models" ]] && { COMPREPLY=(); return; }

      # Generate completions
      COMPREPLY=($(compgen -W "$models" -- "$cur"))
      __ltrim_colon_completions "$cur"
      ;;
    create)
      # Special flag completion
      local -a flags=(--file=-f --quantize=-q)
      COMPREPLY=(${flags[@]})
      __ltrim_colon_completions "$cur"
      ;;
    serve|pull|signin|signout|list|ps|help)
      # No argument completion
      COMPREPLY=( $(compgen -W "" -- "$cur") )
      __ltrim_colon_completions "$cur"
      ;;
  esac
}
complete -F _ollama_completions ollama
```
Note that this code is written in a single line to make it easier to copy and paste. You can format it properly by removing the backslashes and splitting the lines at the appropriate places.


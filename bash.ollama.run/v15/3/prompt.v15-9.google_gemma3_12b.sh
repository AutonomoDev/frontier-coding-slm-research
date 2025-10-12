```bash
#!/bin/bash

_ollama_run_completions() {
  local cur prev
  COMP_WORDBREAKS=":"
  _get_comp_words_by_ref -n : cur prev

  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    COMP_WORDBREAKS="${COMP_WORDBREAKS:+'${COMP_WORDBREAKS}'}" # Restore COMP_WORDBREAKS, handling empty value.

    local models
    models=$(ollama list | tail -n +2 | awk '{print $1}')

    COMPREPLY=($(compgen -W "$models" -- "$COMP_CWORD"))
  else
    COMP_WORDBREAKS="${COMP_WORDBREAKS:+'${COMP_WORDBREAKS}'}"
  fi
}

complete -F _ollama_run_completions ollama
```


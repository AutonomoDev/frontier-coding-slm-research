```bash
#!/bin/bash
# Bash completion for ollama run command

_ollama_run_completions() {
  local cur prev words IFS
  local -a models

  # Handle colons in model names
  local original_wordbreaks="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=':'
  _get_comp_words_by_ref -n : cur prev
  COMP_WORDBREAKS="$original_wordbreaks"

  # Only activate for ollama run subcommand
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get list of models
    models=($(ollama list | tail -n +2 | awk '{print $1}'))

    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "${models[@]}" -- "${cur}") )
  fi
}

complete -F _ollama_run_completions ollama
```


```bash
_ollama_run_completions() {
  local cur prev words comp_words_by_ref_words
  local saved_comp_wordbreaks
  local models

  # Handle model names containing colons
  saved_comp_wordbreaks="${COMP_WORDBREAKS}"
  COMP_WORDBREAKS=""
  _get_comp_words_by_ref -n : cur prev
  COMP_WORDBREAKS="$saved_comp_wordbreaks"

  # Only activate for the 'run' subcommand
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get the list of models from 'ollama list'
    models=$(ollama list | tail -n +2 | awk '{print $1}')

    # Generate completion suggestions
    COMPREPLY=($(compgen -W "$models" -- "$COMP_CWORD"))
  fi
}

complete -F _ollama_run_completions ollama
```


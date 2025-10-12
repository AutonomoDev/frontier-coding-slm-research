```bash
_ollama_run_completions() {
  local cur prev words comp_words
  local saved_comp_wordbreaks

  # Save original COMP_WORDBREAKS
  saved_comp_wordbreaks="${COMP_WORDBREAKS}"

  # Temporarily remove ':' from COMP_WORDBREAKS to handle colons in model names
  COMP_WORDBREAKS=""
  _get_comp_words_by_ref -n : cur prev

  # Check if the subcommand is 'run'
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    # Get the list of models from ollama list
    models=$(ollama list | tail -n +2 | awk '{print $1}')

    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "$models" -- "$COMP_CWORD") )

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$saved_comp_wordbreaks"
  else
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$saved_comp_wordbreaks"
  fi
}

# Register the completion function
complete -F _ollama_run_completions ollama
```


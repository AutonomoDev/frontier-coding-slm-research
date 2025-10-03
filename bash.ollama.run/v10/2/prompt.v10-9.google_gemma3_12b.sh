_ollama_completions() {
  local cur prev models
  local saved_comp_wordbreaks

  # Check if the first argument is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  # Save the original COMP_WORDBREAKS
  saved_comp_wordbreaks="${COMP_WORDBREAKS}"

  # Temporarily remove ':' from COMP_WORDBREAKS to handle colons in model names correctly.
  # Without this, ':' would be treated as a word break, causing issues.
  COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

  # Re-parse the command line using _get_comp_words_by_ref to handle colons in words.
  # -n : tells _get_comp_words_by_ref to treat ':' as not being a word break.
  _get_comp_words_by_ref -n : cur prev

  # Immediately restore the original COMP_WORDBREAKS
  COMP_WORDBREAKS="${saved_comp_wordbreaks}"

  # Generate completions if the previous word is "run"
  if [[ "${prev}" == "run" ]]; then
    # Retrieve available model names from `ollama list`.
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion suggestions for the current word.
    compgen -W "$models" -- "$cur"
  fi

  return 0
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completions ollama

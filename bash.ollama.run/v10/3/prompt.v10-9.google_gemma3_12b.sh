_ollama_completions() {
  local cur prev models
  local saved_comp_worbreaks

  # Check if the subcommand is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  # Save the original COMP_WORDBREAKS to restore it later.
  saved_comp_worbreaks="${COMP_WORDBREAKS}"

  # Temporarily remove ':' from COMP_WORDBREAKS to handle model names with colons.
  COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

  # Re-parse the command line, treating colons as part of words.
  _get_comp_words_by_ref -n : cur prev

  # Restore the original COMP_WORDBREAKS.
  COMP_WORDBREAKS="$saved_comp_worbreaks"

  # If the previous word is "run", generate completions for model names.
  if [[ "$prev" == "run" ]]; then
    # Retrieve model names from the output of "ollama list".
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion suggestions using compgen.
    compgen -W "$models" -- "$cur"
  fi
  return 0
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completions ollama

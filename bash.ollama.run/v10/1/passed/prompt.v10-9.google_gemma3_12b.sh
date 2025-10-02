_ollama_completions() {
  local cur prev models
  local saved_comp_wordbreaks

  # Check if the subcommand is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  # Save the original COMP_WORDBREAKS
  saved_comp_wordbreaks="${COMP_WORDBREAKS}"

  # Temporarily remove ':' from COMP_WORDBREAKS to handle colons in model names.
  # Bash treats ':' as a word break by default, which would split model names like "codellama:13b".
  COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

  # Re-parse the command line using _get_comp_words_by_ref to correctly handle colons.
  _get_comp_words_by_ref -n : cur prev

  # Restore the original COMP_WORDBREAKS immediately after re-parsing.
  COMP_WORDBREAKS="${saved_comp_wordbreaks}"

  # If the previous word is "run", generate completions for model names.
  if [[ "${prev}" == "run" ]]; then
    # Retrieve model names from the output of `ollama list`.
    # awk 'NR>1 {print $1}' extracts the first column from the second line onward.
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion suggestions using compgen.
    # compgen -W "$models" -- "$cur" generates completions from the list of models,
    # filtering by the current word "$cur".
    compgen -W "$models" -- "$cur"
  fi

  return 0
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completions ollama

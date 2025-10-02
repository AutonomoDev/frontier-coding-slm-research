_ollama_completions() {
  local cur prev words models
  local original_comp_wordbreaks

  # Check if the first argument is "run". If not, exit early.
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Save the original COMP_WORDBREAKS.
  original_comp_wordbreaks="$COMP_WORDBREAKS"

  # Remove ':' from COMP_WORDBREAKS to handle model names with colons.
  # This is necessary because Bash normally splits words on colons.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Use _get_comp_words_by_ref to re-parse the current and previous words,
  # ensuring that colons are not treated as word breaks.
  _get_comp_words_by_ref -n : cur prev

  # Restore the original COMP_WORDBREAKS immediately.  Important to prevent
  # side effects on other completions.
  COMP_WORDBREAKS="$original_comp_wordbreaks"

  # If the previous word is "run", generate completions.
  if [[ "$prev" == "run" ]]; then
    # Retrieve model names using ollama list and extract the first column.
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions using compgen.
    compgen -W "$models" -- "$cur"
  fi
}

complete -F _ollama_completions ollama

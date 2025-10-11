# _ollama_completions function to handle completions for the ollama command.
_ollama_completions() {
  # Check if the first argument (COMP_WORDS[1]) is "run".
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Save the original COMP_WORDBREAKS to a local variable.
  local original_word_breaks="${COMP_WORDBREAKS}"

  # Remove the colon (:) from COMP_WORDBREAKS to handle model names with colons correctly.
  # This is necessary because Bash splits words on colons by default, which breaks completion logic.
  COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

  # Re-parse the current and previous words using _get_comp_words_by_ref -n : cur prev.
  # This ensures that colons are not treated as word breaks during parsing.
  _get_comp_words_by_ref -n : cur prev

  # Immediately restore the original COMP_WORDBREAKS to avoid affecting other completions.
  COMP_WORDBREAKS="${original_word_breaks}"

  # If the previous word is "run", generate completions for model names.
  if [[ "${prev}" == "run" ]]; then
    # Retrieve model names from ollama list and extract the first column (model name).
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions using compgen -W "$models" -- "$cur".
    # -W specifies that the completions should be taken from the words in the "$models" variable.
    # -- "$cur" specifies the current word being completed.
    compgen -W "$models" -- "$cur"
  fi
}

# Register the completion function for the ollama command.
# This tells Bash to use the _ollama_completions function to provide completions for the ollama command.
complete -F _ollama_completions ollama

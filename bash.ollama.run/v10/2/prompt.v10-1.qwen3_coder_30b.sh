_ollama_completions() {
  # Check if the subcommand is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  # Save original COMP_WORDBREAKS to restore later
  local orig_comp_wordbreaks="$COMP_WORDBREAKS"

  # Temporarily remove ':' from COMP_WORDBREAKS to prevent word splitting on colons
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Re-parse current and previous words, treating ':' as part of the word
  _get_comp_words_by_ref -n : cur prev

  # Restore original COMP_WORDBREAKS immediately after re-parsing
  COMP_WORDBREAKS="$orig_comp_wordbreaks"

  # If previous word is "run", complete with model names
  if [[ "$prev" == "run" ]]; then
    # Get model names from ollama list, skipping the header line
    local models=$(ollama list | awk 'NR>1 {print $1}')
    # Generate completions based on current input
    compgen -W "$models" -- "$cur" > /dev/null
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
  fi
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama

_ollama_completions() {
  # Check if the subcommand is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
  fi

  # Save original COMP_WORDBREAKS to restore later
  local orig_comp_wordbreaks="$COMP_WORDBREAKS"

  # Temporarily remove ':' from COMP_WORDBREAKS to prevent word splitting on colons
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Re-parse current and previous words using _get_comp_words_by_ref with -n : to avoid colon breaks
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Restore original COMP_WORDBREAKS immediately after re-parsing
  COMP_WORDBREAKS="$orig_comp_wordbreaks"

  # Extract model names from ollama list output (skip header line)
  local models
  models=$(ollama list | awk 'NR>1 {print $1}' | tr '\n' ' ')

  # Generate completions based on current input
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama


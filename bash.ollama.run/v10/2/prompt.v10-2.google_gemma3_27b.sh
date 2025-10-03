# Bash completion script for `ollama run` command

# Function to handle completions for the `ollama` command
_ollama_completions() {
  local cur prev words models
  
  # Check if the first argument is "run"
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Save the original COMP_WORDBREAKS
  local original_wordbreaks="$COMP_WORDBREAKS"

  # Remove colon from COMP_WORDBREAKS to handle model names with colons
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Re-parse the command line using _get_comp_words_by_ref to handle colons correctly
  _get_comp_words_by_ref -n : cur prev

  # Restore the original COMP_WORDBREAKS immediately
  COMP_WORDBREAKS="$original_wordbreaks"

  # If the previous word is "run", generate completions
  if [[ "$prev" == "run" ]]; then
    # Retrieve model names using `ollama list` and extract the first column
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions using `compgen`
    compgen -W "$models" -- "$cur"
  fi
}

# Register the completion function
complete -F _ollama_completions ollama

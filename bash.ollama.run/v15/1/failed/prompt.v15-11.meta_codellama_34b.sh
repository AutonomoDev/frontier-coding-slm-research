_ollama_run_completions() {
  # Save the original COMP_WORDBREAKS and remove ':'
  local saved_comp_wordbreaks="${COMP_WORDBREAKS}"
  local comp_wordbreaks="${saved_comp_wordbreaks//:/}"
  
  # Re-parse current and previous words without ':'
  _get_comp_words_by_ref -n ":" cur prev
  
  # Restore original COMP_WORDBREAKS
  COMP_WORDBREAKS="${saved_comp_wordbreaks}"
  
  # Check if second word is 'run' to activate completion
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi
  
  # Generate model names from `ollama list` output
  local models="$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')"
  
  # Output completion suggestions
  COMPREPLY=($(compgen -W "${models}" -- "${cur}"))
}

complete -F _ollama_run_completions ollama

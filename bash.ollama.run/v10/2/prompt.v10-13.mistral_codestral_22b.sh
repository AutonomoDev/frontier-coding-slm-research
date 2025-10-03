# bash completion for ollama command
_ollama_completions() {
  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  if [[ $prev != "run" ]]; then
    return  # exit early if the previous word is not 'run'
  fi

  # Save original COMP_WORDBREAKS
  local orig_COMP_WORDBREAKS=$COMP_WORDBREAKS

  # Temporarily remove colon from COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

  # Reparse the current and previous words, this time treating colons as regular characters.
  _get_comp_words_by_ref -n : cur prev words cword

  # Immediately restore original COMP_WORDBREAKS to prevent side effects for other commands
  COMP_WORDBREAKS=$orig_COMP_WORDBREAKS

  if [[ $prev == "run" ]]; then
    local models=$(ollama list | awk 'NR>1 {print $1}')  # retrieve model names from ollama list command
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )  # generate reply array for completion
  fi
}

complete -F _ollama_completions ollama  # register the function to handle completions for 'ollama' command

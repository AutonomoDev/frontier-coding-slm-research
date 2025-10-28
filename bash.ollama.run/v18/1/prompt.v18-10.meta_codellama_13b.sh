# [[HUMAN COMMENTED-OUT]]
# Sure, here's an example of how to implement bash completion for the `ollama run` command:

_ollama_completions() {
  # Check if we are in the correct context
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }

  # Get the current word and previous word
  local cur prev
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Parse the list of models
  local models=()
  if command -v ollama &>/dev/null; then
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  fi

  # Complete the model name
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

  # Fix colon completion
  if type __ltrim_colon_completions &>/dev/null; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register the completion function
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This code checks for the correct context (i.e., that `ollama run` is being entered), gets the current and previous words, parses the list of models using `ollama list`, completes the model name with `compgen -W`, and fixes colon completion with `__ltrim_colon_completions`. Finally, it registers the completion function with the `complete` command.
# 
# Note that this code assumes that you have the `ollama` executable in your system path and that the `list` subcommand exists and returns a list of models. If you want to support other commands or different output formats, you'll need to modify the code accordingly.

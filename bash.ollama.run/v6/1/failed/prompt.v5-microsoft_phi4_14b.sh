# Bash completion script for `ollama run` command

_ollama_run_completion() {
  # Check if _get_comp_words_by_ref is available and use it to set 'cur' and 'prev'
  local cur prev words cword
  if declare -F _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref -n : cur prev words cword
  else
    # Fallback for environments where _get_comp_words_by_ref is not available
    cword="${COMP_CWORD}"
    words=("${COMP_WORDS[@]}")
    cur="${words[cword]}"
    prev="${words[cword-1]}"
  fi

  # Ensure the command structure is 'ollama run <model>'
  if [ "${#words[@]}" -ne "$cword" ] || [ "${words[0]}" != "ollama" ] || [ "$prev" != "run" ]; then
    return 1
  fi

  # Get list of models from `ollama list` and parse the output to extract model names
  local model_list
  model_list=$(ollama list | awk 'NR>1 {print $1}')

  # Filter the model list based on current word being typed (cur)
  COMPREPLY=($(compgen -W "$model_list" -- "$cur"))
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama

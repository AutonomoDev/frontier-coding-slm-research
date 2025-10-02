# Complete Bash completion for ollama run
#
# This script provides autocompletion for model names when using the
# `ollama run` command.

_ollama_run_completion() {
  # Find the index of the `run` subcommand.
  run_index=-1
  for i in "${!COMP_WORDS[@]}"; do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only trigger completion if the current word is immediately after `run`.
  if [[ $COMP_CWORD -ne $((run_index + 1)) ]]; then
    return
  fi

  # Get the list of available models.
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # If ollama list fails or returns nothing, exit gracefully.
  if [[ -z "$models" ]]; then
    return
  fi

  # Temporarily remove colon from COMP_WORDBREAKS
  old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:};

  # Filter the model list by the current word.
  cur=${COMP_WORDS[$COMP_CWORD]}
  compgen -W "$models" -- "$cur" > /dev/fd/3

  # Restore COMP_WORDBREAKS
  COMP_WORDBREAKS=$old_wb

  # Remove duplicate suggestions and store in COMPREPLY
  awk '!seen[$0]++' < /dev/fd/3 > /tmp/tmp_completions
  COMPREPLY=($(cat /tmp/tmp_completions))
  rm /tmp/tmp_completions
}

# Register the completion function.
complete -F _ollama_run_completion ollama


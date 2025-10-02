_ollama_run() {
  local cur prev words cword
  _init_completion -n "=" || return

  # Get a list of all available models
  MODELS=$(ollama list | awk '{print $1}' | grep -v '^NAME')

  # Filter the list by the word being completed
  if [[ ${COMP_WORDS[1]} != run ]]; then
    return 1
  fi
  COMPREPLY=()
  while IFS='' read -r line; do
    MODEL=$(echo "$line" | awk '{print $1}')
    if [[ ${COMP_WORDS[2]} == *$MODEL* ]]; then
      COMPREPLY+=("$MODEL")
    fi
  done <<< "$MODELS"

  # Sort the list and return it
  __ltrim_colon_completions "${COMPREPLY[@]}"
  compopt -o default
  return 0
}

complete -F _ollama_run ollama run
# [[HUMAN COMMENTED-OUT]]
#This script uses the `complete` command to define a completion function for the `ollama run` subcommand. The completion function, `_ollama_run`, checks whether the second word in the command line is `run`. If it is not, the function exits with error code 1, indicating that no completions are available.
#
#If the user has typed a partial model name, the function filters the list of all available models to only include those that match the partially typed model name. The filtered list is then sorted and returned as the completion suggestions.
#
#Note that this script uses standard Bash syntax compatible with the `bash-completion` v2 framework. It uses the `_init_completion` function to initialize the completion process, and it uses the `__ltrim_colon_completions` and `compopt -o default` commands to sort and return the completion suggestions.
#

# ollama run completion script
# This script provides autocompletion for the 'ollama run' command,
# suggesting available model names based on the output of 'ollama list'.

# Ensure this script is sourced by bash-completion.
if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
  _get_comp_words_by_ref() {
    echo "$COMP_WORDS"
  }
fi


_ollama_run_completions() {
  local cur prev words
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Only trigger completion after the 'run' subcommand
  if [[ "${COMP_WORDS[1]}" == "run" ]]; then
    words=$(ollama list | awk 'NR>1 {print $1}') # Extract model names, skipping header
    COMPREPLY=( $(compgen -W "$words" -- "$cur") )
  fi
}

# Register the completion function
complete -F _ollama_run_completions ollama run

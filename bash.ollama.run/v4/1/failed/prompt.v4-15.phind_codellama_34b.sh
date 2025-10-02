# Bash completion for ollama command

_ollama_run() {
  # If the second word is not "run", do nothing
  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Get a list of available models, excluding the header line
  local models
  models=$(ollama list --no-trunc | awk 'NR>1 {print $1}')

  # Filter the list based on the current word being completed
  COMPREPLY=($(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Register the completion function for ollama
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#Note: This script assumes that `ollama list` produces output with one model name per line, and that no model names contain spaces or special characters.


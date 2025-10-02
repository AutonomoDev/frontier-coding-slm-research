# Bash Completion Script for ollama run command

_ollama_run_completion() {
  # Ensure we are only completing for 'ollama run <model>'
  if [[ ${COMP_CWORD} -ne 2 || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Capture the current word being typed by the user for filtering suggestions
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Obtain the list of models using 'ollama list' and parse it to extract model names only
  # We use `tail -n +2` to skip the header line.
  # Use `cut` to extract the first column which contains the model names.
  local models
  models=$(ollama list | tail -n +2 | cut -d' ' -f1)

  # Filter model names that start with the current word being typed by user
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama


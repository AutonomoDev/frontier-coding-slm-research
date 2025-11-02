_ollama_run() {
  local cur prev models
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Get the list of models from ollama list, handling potential errors
  models=$(ollama list 2>/dev/null | tr -s '[:space:]' '\n') || return 0

  # Filter models based on the current word prefix
  if [[ ${cur} == *"$prev"* ]]; then
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi

  return 0
}

complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# Installation Instructions:
# 1. Save the above script to a file, e.g., /usr/local/etc/bash_completion.d/ollama.bash
# 2. Source the completion script in your ~/.bashrc or ~/.bash_profile:
#    `source /usr/local/etc/bash_completion.d/ollama.bash`
# 3. (Optional) Reload your shell to activate immediately: `exec bash`

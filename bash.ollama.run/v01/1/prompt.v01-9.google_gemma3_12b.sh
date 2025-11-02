_ollama_run() {
  local cur prev models
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Get list of models, ignoring errors
  models=$(ollama list 2>/dev/null || true)

  if [[ -n "$models" ]]; then
    # Split models into an array
    read -r -a model_array <<< "$models"

    # Filter models based on the current prefix
    COMPREPLY=( "${model_array[@]:0}" )
    COMPREPLY=($(compgen -W "${model_array[@]}" -- "$cur"))
  fi
}

complete -F _ollama_run ollama run

# Installation:
# 1. Save the above script to a file, e.g., /usr/local/etc/bash_completion.d/ollama_run
# 2. Source the script in your .bashrc or .bash_profile:
#    source /usr/local/etc/bash_completion.d/ollama_run
#    (or add it to a file sourced by your shell)
# 3. Restart your shell or type `source ~/.bashrc` (or equivalent) to activate.

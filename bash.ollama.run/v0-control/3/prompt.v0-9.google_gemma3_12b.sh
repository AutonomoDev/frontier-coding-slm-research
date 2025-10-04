_ollama_run() {
  local curcontext="$CURRENT_CONTEXT"
  COMPREPLY=()
  if [[ "${curcontext:0:1}" == "r" ]]; then
    local models
    models=$(ollama list 2>/dev/null | awk '{print $1}') # Extract model names, suppressing errors
    COMPREPLY=( $(compgen -W "$models" -- "$1") )
  fi
  return 0
}

complete -F _ollama_run ollama run

# Installation snippet:
# echo 'complete -F _ollama_run ollama run' >> ~/.bashrc
# source ~/.bashrc

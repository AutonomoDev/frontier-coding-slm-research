#!/bin/bash

_ollama_run() {
  local models=("$(ollama list | tr '\n' ' ')")
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 
# 1. Save the script above to a file (e.g., `ollama-completion.bash`).
# 2. Source the script in your bash profile by adding the following line at the end of the file: `. ~/ollama-completion.bash` or wherever you saved the script.
# 3. Activate the completion immediately by running `complete -F _ollama_run ollama run`.

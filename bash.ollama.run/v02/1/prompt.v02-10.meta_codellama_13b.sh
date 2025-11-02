#!/bin/bash
# ollama_completions.bash: Bash completion script for the "ollama run <model>" command

# Load ollama list output into an array
# This avoids creating a subshell when piping to a while loop
models=()
while IFS=$'\n' read -r line; do
  models+=("$line")
done < <(ollama list)

# Trigger completion only after "run" and with nothing typed
_ollama_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  if [[ "$cur" == run* ]]; then
    # Filter models by prefix
    COMPREPLY=($(compgen -W "${models[@]}" -- $cur))
    # Sort completions alphabetically
    sort -u <<<"${COMPREPLY[@]}" >/dev/null 2>&1
  fi
}

# Register completion function with "ollama" command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Installation instructions:
# 1. Save the script above to a file (e.g., `ollama_completions.bash`)
# 2. Add `source /path/to/ollama_completions.bash` to your `.bashrc` file or equivalent
# 3. Reload your shell environment for the changes to take effect

```bash
#!/bin/bash
# Bash completion for `ollama run <model>`

_ollama_run_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "$prev" != "ollama" || "$cur" != "run" ]]; then
    return
  fi

  # Get the list of models from `ollama list`.  Handle failure silently.
  models=($(ollama list 2>/dev/null))

  if [[ -z "${models[0]}" ]]; then
    return # No models found or command failed
  fi

  # Filter the models based on the current word prefix.
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      COMPREPLY+=("$model")
    fi
  done
}

complete -f _ollama_run_completion ollama run

# Installation:
# 1. Save this script to a file, e.g., ~/.ollama_completion.bash
# 2. Source it: `source ~/.ollama_completion.bash`
# 3. To activate immediately, run: `complete -f _ollama_run_completion ollama run`
```


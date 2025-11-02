```bash
#!/bin/bash
# Bash completion for ollama run <model>

_ollama_run_completion() {
  local cur prev words cword
  _init_completion

  # Get the current word and the word before it
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Only trigger completion after 'ollama run'
  if [[ "${prev}" != "run" ]]; then
    return 1
  fi

  # Get the list of available models
  local models=$(ollama list 2>/dev/null) # Silently ignore errors from ollama list

  # If ollama list failed, return immediately
  if [[ -z "$models" ]]; then
    return 0
  fi

  # Split the output into an array of models
  read -r -a model_array <<< "$models"

  # Filter models based on the current prefix
  COMPREPLY=( $(compgen -W "${model_array[*]}" -- "${cur}") )

  return 0
}

complete -F _ollama_run_completion ollama

# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama_run.bash
# 2. Source the script: source ~/.bash_completion.d/ollama_run.bash
# 3. Or, source ~/.bash_completion to load all completion scripts.
# 4. Restart your shell or run 'source ~/.bashrc' to activate immediately.
```


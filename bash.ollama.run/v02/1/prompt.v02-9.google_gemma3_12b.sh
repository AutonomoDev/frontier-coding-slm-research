```bash
# Bash completion for ollama run <model>
# Dynamically lists available models from ollama list

_ollama_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local models
  local matches

  # Capture ollama list output safely
  models=$(ollama list 2>/dev/null)

  # Handle failure: If ollama list fails, do nothing
  if [[ -z "$models" ]]; then
    return 0
  fi

  # Split the output into an array, handling whitespace
  COMPREPLY=()
  local model_array=($models)

  # Filter models based on the current word being completed
  for model in "${model_array[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      COMPREPLY+=("$model")
    fi
  done

  # Sort the matches alphabetically
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
}

# Register the completion function for ollama
complete -F _ollama_completion ollama

# Installation/Activation
# 1. Save this script to a file, e.g., /usr/local/etc/bash_completion.d/ollama
# 2. Source the file in your .bashrc or .bash_profile:
#    `source /usr/local/etc/bash_completion.d/ollama`
#    or add the above line to your .bashrc/profile.
# 3. Reload your shell: `source ~/.bashrc` or `source ~/.bash_profile`
```


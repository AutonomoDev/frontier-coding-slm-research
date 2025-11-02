```bash
# ollama run completion script

_ollama() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local models
  local i

  # Capture the output of ollama list.  Error silently if ollama list fails.
  models=$('ollama list' 2>/dev/null) || return

  # Filter the models based on the current word being completed.
  local matches=()
  for model in $models; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches alphabetically.
  matches=($(printf "%s\n" "${matches[@]}" | sort))

  # Assign the matches to COMPREPLY.
  COMPREPLY=("${matches[@]}")
}

# Register the completion function for ollama run.
complete -F _ollama ollama run

# Installation/Activation:
# 1. Save the above script to a file, e.g., ~/.bash_completions/ollama.bash
# 2. Source the script in your .bashrc or .bash_profile:
#    echo 'source ~/.bash_completions/ollama.bash' >> ~/.bashrc
# 3. Reload your .bashrc: source ~/.bashrc
```


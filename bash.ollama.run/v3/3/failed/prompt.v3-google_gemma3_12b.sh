_ollama_run_completion() {
  local cur prev models completions
  # Check if the previous word was 'run' and the command is 'ollama'.
  prev=$(printf '%s' "${COMP_WORDS[@]:0:${COMP_CWORD}-1}")
  cur="${COMP_WORDS[$COMP_CWORD]}"
  command=$(printf '%s' "${COMP_WORDS[@]:0:1}")

  if [[ "$command" == "ollama" && "$prev" == "run" ]]; then
    # Retrieve the list of models from 'ollama list'.
    models=$(ollama list 2>/dev/null) || return 0 # Capture output; exit silently on error

    if [[ -n "$models" ]]; then
      # Iterate over the models and filter based on the prefix.
      local model
      completions=()
      while IFS= read -r model; do
        if [[ "$model" == "$cur"* ]]; then
          completions+=("$model")
        fi
      done <<< "$models"

      # Sort the completions alphabetically.
      completions=($(printf '%s\n' "${completions[@]}" | sort))

      # Populate COMPREPLY.
      COMPREPLY=("${completions[@]}")
    fi
  fi
}

# Wiring to 'ollama'.
complete -F _ollama_run_completion ollama

# Installation instructions:
# 1. Save this script to a file, e.g., ~/ollama_completion.bash
# 2. Add the following line to your ~/.bashrc:
#    source ~/ollama_completion.bash
# 3. Reload your .bashrc:
#    source ~/.bashrc


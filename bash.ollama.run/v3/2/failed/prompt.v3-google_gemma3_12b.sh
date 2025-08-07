_ollama_run_completion() {
  local cur prev words models
  local i

  # Check if the previous word is "run" and the command is "ollama"
  prev="${COMP_WORDS[COMP_CWORD-2]}"
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ "$prev" == "run" && "$(command -v ollama 2> /dev/null)" != "" ]]; then

    # Get the list of models from `ollama list`
    models=$(ollama list 2>/dev/null)
    if [[ -n "$models" ]]; then
      # Split the output into an array
      IFS=$'\n' read -r -d '' -a models_array <<< "$models"

      # Filter models based on the current word
      local filtered_models=()
      for model in "${models_array[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
          filtered_models+=("$model")
        fi
      done

      # Sort the filtered models alphabetically
      filtered_models=($(printf '%s\n' "${filtered_models[@]}" | sort))

      # Populate COMPREPLY
      COMPREPLY=("${filtered_models[@]}")

    fi
  fi
}

# Wiring: Attach the function to 'ollama'
complete -F _ollama_run_completion ollama

# Installation/Activation:
#
# 1. Save this script to a file, e.g., `ollama_completion.bash`.
# 2. Add the following line to your `.bashrc` file:
#    `source /path/to/ollama_completion.bash` (replace with the actual path)
# 3. Reload your `.bashrc`: `source ~/.bashrc` or open a new terminal.


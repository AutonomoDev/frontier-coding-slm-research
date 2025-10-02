_ollama_run_completion() {
  local cur prev models completions
  # Check if the previous word is "run" and the command is "ollama"
  if [[ "${COMP_WORDS[COMP_CWORD-1]}" == "run" && "${COMP_WORDS[0]}" == "ollama" ]]; then
    # Retrieve the list of models
    models=$(ollama list)
    if [[ -z "$models" || "$?" -ne 0 ]]; then
      return 0  # No completions if ollama list fails or is empty
    fi

    # Split the output of ollama list into an array
    models_array=($(echo "$models" | grep -oP '^\s*\K[^ ]+' ))

    # Filter models based on the current word
    local cur="${COMP_WORDS[COMP_CWORD]}"
    completions=()
    for model in "${models_array[@]}"; do
      if [[ "$model" == "$cur"* ]]; then
        completions+=("$model")
      fi
    done

    # Sort the completions alphabetically
    sorted_completions=$(printf "%s\n" "${completions[@]}" | sort)

    # Assign the sorted completions to COMPREPLY
    COMPREPLY=($(compgen -W "$sorted_completions" -- "$cur"))
  fi
}

# Wiring: Attach the completion function to ollama
complete -F _ollama_run_completion ollama

# Installation Instructions:
# 1. Save the above script to a file, e.g., /usr/local/etc/bash_completion.d/ollama
# 2. Source the script in your .bashrc or .bash_profile:
#    source /usr/local/etc/bash_completion.d/ollama
# 3. Reload your shell:
#    exec bash


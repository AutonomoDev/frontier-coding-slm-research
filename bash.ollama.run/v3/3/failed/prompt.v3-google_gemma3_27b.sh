```bash
#!/bin/bash
# Completion for `ollama run <model>`

_ollama_run_completion() {
  local cur prev command
  # Use _get_comp_words_by_ref if available (Bash 5.1+)
  if declare -f _get_comp_words_by_ref > /dev/null 2>&1; then
    _get_comp_words_by_ref ollama run
  else
    # Fallback for older Bash versions
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only trigger for `ollama run`
  if [[ "$prev" == "run" && "$command" == "ollama" ]]; then
    # Get the list of available models
    ollama_list_output=$(ollama list)

    # Check if ollama list succeeded and has output
    if [[ -n "$ollama_list_output" ]]; then
      # Split the output into an array
      IFS=$'\n' read -r -d '' -a models <<< "$ollama_list_output"
      unset IFS

      # Filter models based on the current word
      filtered_models=()
      for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
          filtered_models+=("$model")
        fi
      done

      # Sort the filtered models alphabetically
      sorted_models=($(printf '%s\n' "${filtered_models[@]}" | sort))

      # Assign the sorted models to COMPREPLY
      COMPREPLY=($(compgen -W "${sorted_models[@]}" -- "$cur"))
    fi
  fi
}

complete -F _ollama_run_completion ollama

# Installation:
# 1. Save this script to a file (e.g., ~/.ollama_completion.bash)
# 2. Add the following line to your ~/.bashrc:
#    source ~/.ollama_completion.bash
# 3. Reload your .bashrc:
#    source ~/.bashrc
```


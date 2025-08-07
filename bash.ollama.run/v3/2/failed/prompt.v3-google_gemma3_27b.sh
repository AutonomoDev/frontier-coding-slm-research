```bash
#!/bin/bash

_ollama_run_complete() {
  local cur prev words cword
  # Use _get_comp_words_by_ref if available, otherwise fallback
  if declare -F _get_comp_words_by_ref > /dev/null 2>&1; then
    _get_comp_words_by_ref
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only trigger after 'ollama run'
  if [[ "$prev" == "run" && "$words[0]" == "ollama" ]]; then
    # Get model list once
    local model_list_output
    model_list_output=$(ollama list 2>/dev/null)

    # Check if ollama list failed or returned empty
    if [[ -z "$model_list_output" ]]; then
      return
    fi

    # Split the output into an array (handle newlines correctly)
    local -a models
    read -r -d $'\n' -a models <<< "$model_list_output"

    # Filter models based on the current word
    local -a filtered_models
    for model in "${models[@]}"; do
      if [[ "$model" == "$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done

    # Sort the filtered models alphabetically
    local -a sorted_models
    sorted_models=("${filtered_models[@]}")
    IFS=$'\n' sorted_models=($(printf "%s\n" "${sorted_models[@]}" | sort))
    unset IFS

    # Populate COMPREPLY
    COMPREPLY=("${sorted_models[@]}")
  fi
}

complete -F _ollama_run_complete ollama

# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama_run.bash
# 2. Add the following line to your ~/.bashrc:
#    source ~/.bash_completion.d/ollama_run.bash
# 3. Reload your shell: source ~/.bashrc


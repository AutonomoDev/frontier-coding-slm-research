# Bash completion for `ollama run <model>`
complete -F _ollama_run_completion ollama

_ollama_run_completion() {
  local cur prev opts
  compgen -W "" # Reset existing completions

  cur="${COMP_WORDS[COMP_CWORD]}" # Current word being completed
  prev="${COMP_WORDS[COMP_CWORD-1]}" # Previous word
  
  # Only trigger completions after `ollama run`
  if [[ "$prev" == "run" ]]; then
    # Capture output of `ollama list`
    local ollama_list_output
    ollama_list_output=$(ollama list 2>/dev/null) # Redirect stderr to avoid error messages

    # Check if `ollama list` was successful (empty output is also considered success)
    if [[ -n "$ollama_list_output" ]]; then
      # Split the output into an array (handling both space and newline separated models)
      local models=()
      if [[ "$ollama_list_output" == *[[:space:]]* ]]; then
        # Space separated
        IFS=' ' read -r -a models <<< "$ollama_list_output"
      else
        # Newline separated
        while IFS= read -r model; do
          models+=("$model")
        done <<< "$ollama_list_output"
      fi

      # Filter models based on the current word (prefix matching)
      local filtered_models=()
      for model in "${models[@]}"; do
        if [[ "${model:0:${#cur}}" == "$cur" ]]; then
          filtered_models+=("$model")
        fi
      done

      # Sort the filtered models alphabetically
      sorted_models=($(printf "%s\n" "${filtered_models[@]}" | sort))

      # Assign the sorted models to COMPREPLY
      COMPREPLY=( "${sorted_models[@]}" )
    fi
  fi
}

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama-run
# 2. Source the file: source ~/.bash_completion.d/ollama-run
# 3. (Or, add the following line to your ~/.bashrc and reload your shell:)
#    source ~/.bash_completion.d/ollama-run
# 4. Reload your shell: exec bash

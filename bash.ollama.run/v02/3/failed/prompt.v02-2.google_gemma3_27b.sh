complete -F _ollama_run_completion ollama

_ollama_run_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}" # Current word being completed
  prev="${COMP_WORDS[COMP_CWORD-1]}" # Previous word
  
  # Only trigger completions after "ollama run"
  if [[ "$prev" == "run" ]]; then
    # Capture the output of ollama list
    local ollama_list_output
    ollama_list_output=$(ollama list 2>/dev/null) # Redirect stderr to avoid error messages

    # Check if ollama list was successful
    if [[ -n "$ollama_list_output" ]]; then
      # Split the output into an array. Handles both space- and newline-separated models
      local models=($ollama_list_output)

      # Filter models based on the current word being completed (prefix matching)
      local filtered_models=()
      for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
          filtered_models+=("$model")
        fi
      done

      # Sort the filtered models alphabetically
      sorted_models=$(printf '%s\n' "${filtered_models[@]}" | sort)
      
      # Populate COMPREPLY with the sorted, filtered models
      COMPREPLY=( $(compgen -W "$sorted_models" -- "$cur") )
    fi
  fi
  
  return 0
}

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama-run
# 2. Add the following line to your ~/.bashrc:
#    source ~/.bash_completion.d/ollama-run
# 3. Reload your bash configuration: source ~/.bashrc

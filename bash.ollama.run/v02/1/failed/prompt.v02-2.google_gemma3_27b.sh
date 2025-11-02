complete -F _ollama_run ollama

_ollama_run() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}" # Current word being completed
  prev="${COMP_WORDS[COMP_CWORD-1]}" # Previous word
  
  # Only trigger completion after "ollama run"
  if [[ "$prev" == "run" ]]; then
    # Capture the output of ollama list
    local ollama_list_output
    ollama_list_output=$(ollama list 2>/dev/null)  # Redirect stderr to avoid error messages
    
    # Check if ollama list succeeded.  If not, return with no completions
    if [[ -z "$ollama_list_output" ]]; then
      return
    fi

    # Split the output into an array. Handles both one model per line and whitespace-separated models
    local -a models
    read -r -a models <<< "$ollama_list_output"
    
    # Filter models based on the current word
    local -a filtered_models
    for model in "${models[@]}"; do
      if [[ "$model" == "$cur"* ]]; then
        filtered_models+=("$model")
      fi
    done
    
    # Sort the filtered models alphabetically
    sorted_models=($(printf '%s\n' "${filtered_models[@]}" | sort))

    # Populate COMPREPLY with the sorted and filtered models
    COMPREPLY=("${sorted_models[@]}")
  fi
}

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 1. Save this script to ~/.bash_completion.d/ollama-run
# 2. Source it in your .bashrc:  source ~/.bash_completion.d/ollama-run
# 3. Reload your bash configuration: source ~/.bashrc

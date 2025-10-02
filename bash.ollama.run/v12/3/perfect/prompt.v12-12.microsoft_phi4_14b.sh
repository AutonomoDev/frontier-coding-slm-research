_ollama_completions() {
  # Check if the command is 'ollama run'
  if [[ "${COMP_CWORD}" -le 1 ]]; then
    COMPREPLY=()
    return
  fi

  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  # If this isn't the ollama command or not preceded by 'run', do nothing.
  if [[ "${words[0]}" != "ollama" || "${prev}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Check if 'ollama' is a valid command
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Array to hold model names from the ollama list output
  local models=()

  # Run ollama list and capture its output
  local ollama_list_output
  ollama_list_output=$(ollama list 2>/dev/null)

  if [[ -z "$ollama_list_output" ]]; then
    COMPREPLY=()
    return
  fi

  # Parse the model names, skipping header and empty lines
  while IFS=$'\n' read -r line; do
    if [[ "$line" =~ ^NAME\ ID\ SIZE\ MODIFIED$ || -z "$line" ]]; then
      continue
    fi
    local model_name=$(echo "$line" | awk '{print $1}')
    models+=("$model_name")
  done <<< "$ollama_list_output"

  # If no models found, return an empty array
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Array to hold matching model names that start with current word
  local matches=()

  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches before completing
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Set the completion suggestions
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # Fix colon-splitting issues by trimming colons from the beginning of $cur
  __ltrim_colon_completions "$cur"
}

# Register the function with bash-completion for 'ollama'
complete -F _ollama_completions ollama

_ollama_completions() {
  # Check if the first word is "ollama" and previous word is "run"
  if [[ "${COMP_CWORD}" -le 1 || "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[${COMP_CWORD}-1]}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle splitting on colons using _get_comp_words_by_ref if available, otherwise fallback to COMP_WORDS
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the 'ollama' command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Get the list of models from ollama
  local IFS=$'\n'
  local models=()
  while read -r line; do
    # Skip header and empty lines
    [[ "$line" =~ ^NAME\ ID\ SIZE\ MODIFIED$ || -z "$line" ]] && continue
    # Extract the first column (model name) using awk
    model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models are found, exit early
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Find matches that start with the current word being typed
  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches and set COMPREPLY with completion options
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # Always call __ltrim_colon_completions to handle colon splitting correctly
  if type __ltrim_colon_completions > /dev/null 2>&1; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama

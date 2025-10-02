_ollama_completions() {
  # Check if we are completing after "ollama run"
  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[COMP_CWORD-1]}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle colons properly by preventing Bash from splitting on ':'
  # Use _get_comp_words_by_ref if available (bash-completion 2+)
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for older versions or when _get_comp_words_by_ref is not available
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Ensure ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Read models from ollama list, parse only the first column (model names)
  local models=()
  while IFS= read -r line; do
    # Skip header and empty lines
    if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
      continue
    fi
    # Extract first column (model name) using awk
    local model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models found, return early
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Find matches that start with current input
  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # If no matches, return early
  if [[ ${#matches[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Sort matches to make suggestions orderly
  local sorted_matches
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Generate completions
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # CRITICAL: Fix colon handling for display after typing a colon like "codellama:"
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completions ollama

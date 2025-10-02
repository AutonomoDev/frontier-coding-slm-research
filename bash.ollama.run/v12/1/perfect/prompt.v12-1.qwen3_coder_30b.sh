_ollama_completions() {
  local cur prev
  # Tell bash not to split on colons, which breaks completion for model names like codellama:13b
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for older bash-completion versions
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only complete after "ollama run"
  if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  local models=()
  local line
  # Read ollama list output line by line
  while IFS= read -r line; do
    # Skip header and empty lines
    if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
      continue
    fi
    # Extract only the model name (first column)
    local model_name
    model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models found, return empty completion
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

  # Sort matches for consistent ordering
  local sorted_matches
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Generate completions from sorted matches
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  # Fix colon handling: trim colon completions so suggestions show properly after codellama:
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the ollama command
complete -F _ollama_completions ollama

_ollama_completions() {
  local cur prev words cword
  # Use _get_comp_words_by_ref to handle colons properly, with fallback for systems without bash-completion
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion loaded
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only provide completions when the previous word is "run"
  if [[ "${prev}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Retrieve model names from ollama list, skipping header line
  local models=()
  while IFS= read -r line; do
    # Skip empty lines and header
    if [[ -z "$line" ]] || [[ "$line" == "NAME"* ]]; then
      continue
    fi
    # Extract first column (model name) from the line
    local model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list)

  # If no models found, return empty completion
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Build sorted matches based on current input
  local sorted_matches=""
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      sorted_matches="$sorted_matches $model"
    fi
  done

  # Generate completions using compgen
  if [[ -n "$sorted_matches" ]]; then
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
  else
    COMPREPLY=()
  fi

  # Trim colon completions to avoid display issues
  __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama
complete -F _ollama_completions ollama

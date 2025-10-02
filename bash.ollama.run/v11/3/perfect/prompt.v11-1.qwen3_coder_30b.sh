_ollama_completions() {
  local cur prev words cword
  # Use _get_comp_words_by_ref to handle colons properly, with fallback for systems without bash-completion
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion loaded
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only complete after "ollama run"
  if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Retrieve model names from ollama list, parse first column (name), skip header
  local models=()
  while IFS= read -r line; do
    # Skip header line
    if [[ "$line" == "NAME"* ]]; then
      continue
    fi
    # Extract first column (model name)
    local model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models found, return empty completion
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return
  fi

  # Generate matches based on current input
  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort matches and generate COMPREPLY
  if [[ ${#matches[@]} -gt 0 ]]; then
    local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
  else
    COMPREPLY=()
  fi

  # CRITICAL: Trim colons from completions to avoid incorrect display
  __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

_ollama_completions() {
  # Check if the first word is "ollama" and the previous word is "run"
  local cur prev words cword
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # If the first word is not "ollama" or the previous word is not "run", return early
  if [[ "$prev" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Check if `ollama` command exists
  if ! command -v ollama &> /dev/null; then
    COMPREPLY=()
    return 0
  fi

  local models=()
  # Get model names from `ollama list`
  while IFS= read -r line; do
    # Skip header and empty lines
    if [[ "$line" == "NAME ID SIZE MODIFIED" || -z "$line" ]]; then
      continue
    fi

    # Extract the first column (model name)
    local model_name=$(echo "$line" | awk '{print $1}')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done < <(ollama list 2>/dev/null)

  # If no models found, return early
  if [[ ${#models[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort the matches
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

  # Set COMPREPLY with the sorted matches
  COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

  # CRITICAL: Fix suggestions after colons
  __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama

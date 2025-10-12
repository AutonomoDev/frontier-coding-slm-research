_ollama_completions() {
  # Check if command is "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  local cur="${COMP_WORDS[2]}" # Current word being completed
  local prev="${COMP_WORDS[1]}" # Previous word
  local models=()

  # Handle colons: try to split by colon
  if _get_comp_words_by_ref -n : cur prev; then
    # Colon handling successful
    : # Do nothing
  else
    # Fallback: manual extraction from COMP_WORDS
    cur="${COMP_WORDS[2]}"
  fi

  # Check if ollama command exists
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=();
    return
  fi

  # Get model list from ollama list
  local ollama_list_output
  ollama_list_output=$(ollama list 2>/dev/null)

  # Parse ollama list output
  while IFS= read -r line; do
    # Skip header line
    if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
      continue
    fi

    # Extract model name (first column)
    model_name=$(echo "$line" | awk '{print $1}')

    # Add to models array
    models+=("$model_name")
  done <<< "$ollama_list_output"

  # Filter models matching current prefix
  local filtered_models=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      filtered_models+=("$model")
    fi
  done

  # Sort results
  filtered_models=($(printf '%s\n' "${filtered_models[@]}" | sort))

  # Generate completions
  COMPREPLY=( $(compgen -W "${filtered_models[@]}" -- "$cur") )

  # Fix colon display (MANDATORY)
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

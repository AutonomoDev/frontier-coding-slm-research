_ollama_completions() {
  # Ensure we are completing for 'ollama' and the previous word is 'run'
  if [[ "${COMP_CWORD}" -le 1 || "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Handle colon-separated completions properly
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Proceed only if previous word is 'run'
  if [[ "${prev}" != "run" ]]; then
    return
  fi

  # Ensure ollama command exists before proceeding
  if ! type ollama &> /dev/null; then
    COMPREPLY=()
    return
  fi

  # Retrieve and parse model names from `ollama list`
  local models=()
  local line model

  # Run `ollama list` and capture output, handle potential failures gracefully
  if ! models_output=$(timeout 2 ollama list 2>/dev/null); then
    COMPREPLY=()
    return
  fi

  # Skip header and extract first column (model names)
  while IFS=$'\n' read -r line || [[ -n "$line" ]]; do
    model="${line%% *}"
    models+=("$model")
  done <<< "${models_output}"

  # Filter matches based on current input
  local -a matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # Sort and generate completion suggestions
  IFS=$'\n' sorted_matches=($(echo "${matches[*]}" | tr ' ' '\n' | sort -u))
  COMPREPLY=($(compgen -W "${sorted_matches[*]}" -- "$cur"))

  # Handle colon-separated completions display
  __ltrim_colon_completions "$cur"
}

# Register the completion function with bash-completion framework
complete -F _ollama_completions ollama

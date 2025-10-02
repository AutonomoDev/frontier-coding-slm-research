# Function to handle completions for the `ollama` command
_ollama_completions() {
  local cur prev

  # Check if bash-completion is available and use _get_comp_words_by_ref with -n : flag
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion loaded
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the command is "ollama" and previous word is "run"
  if [[ "${prev}" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Retrieve model names using `ollama list` and parse with awk/while loop to extract first column, skipping header
  local models
  if command -v ollama > /dev/null; then
    models=$(ollama list | awk 'NR>1 {print $1}')
  else
    COMPREPLY=()
    return 0
  fi

  # Handle empty or failed `ollama list` output gracefully
  if [[ -z "$models" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Filter matches using array iteration and pattern matching against `$cur`
  local sorted_matches
  for model in $models; do
    if [[ "$model" == "$cur"* ]]; then
      sorted_matches+=("$model")
    fi
  done

  # Sort matches and use `compgen -W` to generate COMPREPLY
  IFS=$'\n' sorted_matches=($(sort <<<"${sorted_matches[*]}"))
  unset IFS
  COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

  # CRITICAL: Call __ltrim_colon_completions to handle colon-separated completions display properly
  __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama

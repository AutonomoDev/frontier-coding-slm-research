_ollama_run_model_completion() {
  local cur prev words cword
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Ensure we're completing for 'ollama run'
  if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Check if ollama command is available
  if ! command -v ollama >/dev/null 2>&1; then
    COMPREPLY=()
    return 0
  fi

  # Fetch model list
  local models=()
  local output
  output=$(ollama list 2>/dev/null)
  if [[ $? -ne 0 ]] || [[ -z "$output" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Parse model names, skipping header
  while IFS= read -r line; do
    if [[ "$line" =~ ^NAME[[:space:]]+ ]] || [[ -z "$line" ]]; then
      continue
    fi
    # Extract first column, trim whitespace
    local model_name
    model_name=$(echo "$line" | awk '{print $1}' | tr -d '[:space:]')
    if [[ -n "$model_name" ]]; then
      models+=("$model_name")
    fi
  done <<< "$output"

  # Generate matching completions
  local matches=()
  local model
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done

  # If no matches, return empty completions
  if [[ ${#matches[@]} -eq 0 ]]; then
    COMPREPLY=()
    return 0
  fi

  # Sort and generate completions
  local sorted_matches
  sorted_matches=$(printf '%s\n' "${matches[@]}" | sort -u)
  COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

  __ltrim_colon_completions "$cur"
}

# Register completion without default file completion
complete -F _ollama_run_model_completion -o nosort ollama

# To install and activate this script:
# 1. Save this file to ~/.bash_completion.d/ollama-completion.sh
# 2. Add the following line to your ~/.bashrc:
#    source ~/.bash_completion.d/ollama-completion.sh
# Note: This script assumes that bash-completion is installed and loaded (usually via /etc/bash_completion or similar in your .bashrc),
# as it relies on helper functions like _get_comp_words_by_ref and __ltrim_colon_completions for proper handling of colons in model names.
# If you encounter issues with colons, ensure bash-completion is sourced in your shell.
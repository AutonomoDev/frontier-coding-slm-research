#!/bin/bash

# _ollama_completions: Bash completion function for ollama run command.
_ollama_completions() {
  local cur prev words
  local sorted_matches

  # Check if the command is "ollama" and the previous word is "run".
  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Use _get_comp_words_by_ref to handle colons in model names correctly.
  # The -n : flag prevents splitting on colons, allowing for proper parsing of model names like codellama:13b.
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion or if _get_comp_words_by_ref fails.
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # If the previous word is not "run", return early.
  if [[ "${prev}" != "run" ]]; then
    return
  fi

  # Check if the ollama command exists.
  if ! command -v ollama &> /dev/null; then
    echo "ollama command not found." >&2
    return 1
  fi

  # Retrieve model names using ollama list and parse the output.
  local ollama_list_output
  ollama_list_output=$(ollama list)

  if [[ -z "$ollama_list_output" ]]; then
    COMPREPLY=()
    return
  fi

  # Extract model names from the output, skipping the header row.
  local model_names=()
  while IFS= read -r line; do
    # Skip the header line
    if [[ "$line" == "NAME"* ]]; then
      continue
    fi

    # Extract the first column (model name)
    model_name=$(echo "$line" | awk '{print $1}')
    model_names+=("$model_name")
  done <<< "$ollama_list_output"

  # Filter model names based on the current input.
  local filtered_matches=()
  for model_name in "${model_names[@]}"; do
    if [[ "$model_name" == *"$cur"* ]]; then
      filtered_matches+=("$model_name")
    fi
  done

  # Sort the filtered model names.
  sorted_matches=($(printf "%s\n" "${filtered_matches[@]}" | sort))

  # Generate completions using compgen.
  COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

  # CRITICAL: Call __ltrim_colon_completions to handle colon-separated completions correctly.
  # This ensures that the completions are displayed properly, without extra characters or incorrect parsing.
  __ltrim_colon_completions "$cur"
}

# Register the completion function for the ollama command.
complete -F _ollama_completions ollama


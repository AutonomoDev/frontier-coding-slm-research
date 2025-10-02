#!/bin/bash
# Bash completion script for the `ollama run` command.

_ollama_completions() {
  local cur prev words IFS
  local sorted_matches
  local command
  local ollama_list_output

  # Get the current and previous words.  Use _get_comp_words_by_ref to handle colons correctly.
  # -n : tells _get_comp_words_by_ref to not split on colons.
  if ! _get_comp_words_by_ref -n : cur prev; then
    # Fallback for systems without bash-completion.
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Check if the command is "ollama" and the previous word is "run".
  if [[ "${prev}" != "run" ]]; then
    return 0 # Return early if not completing after "ollama run".
  fi

  # Check if the ollama command exists
  if ! command -v ollama &> /dev/null; then
    echo "ollama command not found. Please install ollama." >&2
    return 1
  fi

  # Retrieve model names using `ollama list`.
  ollama_list_output=$(ollama list 2>&1)

  # Handle empty or failed ollama list output.
  if [[ -z "$ollama_list_output" ]]; then
    COMPREPLY=()
    return 0
  fi

  # Parse the output of `ollama list` and extract model names, skipping header.
  local model_names=()
  IFS=$'\n'
  read -r -d '' -a lines <<< "$ollama_list_output"
  unset IFS

  # Skip the header line.
  for ((i=1; i<${#lines[@]}; i++)); do
    local line="${lines[i]}"
    local model_name=$(echo "$line" | awk '{print $1}') # Extract the first column.
    model_names+=("$model_name")
  done

  # Filter matches based on the current word.
  local filtered_matches=()
  for model in "${model_names[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      filtered_matches+=("$model")
    fi
  done

  # Sort the matches.
  sorted_matches=($(printf "%s\n" "${filtered_matches[@]}" | sort))

  # Generate completions using `compgen`.
  COMPREPLY=( $(compgen -W "${sorted_matches[@]}" -- "$cur") )

  # CRITICAL: Handle colon-separated completions display.
  # __ltrim_colon_completions removes leading colons from the completion suggestions,
  # ensuring proper display of model names like "codellama:13b".  Without this,
  # Bash would interpret the colon as a separator and display incorrect suggestions.
  __ltrim_colon_completions "$cur"

  return 0
}

# Register the completion function.
complete -F _ollama_completions ollama

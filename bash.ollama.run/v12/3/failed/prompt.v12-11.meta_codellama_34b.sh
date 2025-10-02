#!/bin/bash

# Function Structure
_ollama_completions() {
  # Subcommand Check
  if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${COMP_WORDS[1]}" != "run" ]]; then
    COMPREPLY=()
    return
  fi

  # Handle Colons (IMPORTANT)
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Completion Logic
  if [[ "$prev" == "run" ]]; then
    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
      COMPREPLY=()
      return
    fi

    # Read ollama list line by line in a while loop
    while IFS= read -r line; do
      # Skip header and empty lines
      if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
        continue
      fi

      # Use awk to get only the model name (first column)
      model=$(echo "$line" | awk '{print $1}')

      # Add to local array if not empty
      if [[ -n "$model" ]]; then
        models+=("$model")
      fi
    done < <(ollama list 2>/dev/null)

    # If models array is empty, set COMPREPLY=() and return
    if (( ${#models[@]} == 0 )); then
      COMPREPLY=()
      return
    fi

    # Make another array for matches: loop through models, add if it starts with "$cur"
    matches=()
    for model in "${models[@]}"; do
      if [[ "$model" == "$cur"* ]]; then
        matches+=("$model")
      fi
    done

    # Sort the matches: sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Set COMPREPLY with compgen -W "$sorted_matches" -- "$cur"
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # CRITICAL COLON FIX (DO NOT SKIP): After COMPREPLY, ALWAYS call __ltrim_colon_completions "$cur"
    __ltrim_colon_completions "$cur"
  fi
}

# Register
complete -F _ollama_completions ollama

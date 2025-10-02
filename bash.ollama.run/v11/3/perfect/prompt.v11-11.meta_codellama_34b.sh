#!/bin/bash

# _ollama_completions() - Generate completions for the `ollama` command.
# @param $1 : Previous word in current completion context
# @param $2 : Current word being completed
# @param $3 : Cursor position at the beginning of the current word
function _ollama_completions() {
  # Check if command is "ollama" and previous word is "run".
  # If not, return early with empty COMPREPLY.
  local cur prev words cword
  _get_comp_words_by_ref -n =: cur prev words cword
  if [ "${prev}" != "run" ]; then
    COMPREPLY=()
    return 0
  fi

  # Retrieve model names using `ollama list` and parse with awk/while loop to extract first column, skipping header.
  local models="$(ollama list | tail -n +2 | cut -d ' ' -f 1)"

  # Filter matches using array iteration and pattern matching against $cur.
  local model
  for model in ${models}; do
    if [[ "$model" == "$cur"* ]]; then
      COMPREPLY+=("${model}")
    fi
  done

  # Sort matches and use `compgen -W` to generate COMPREPLY.
  local sorted_matches=$(printf '%s\n' "${COMPREPLY[@]}" | sort)
  COMPREPLY=($(compgen -W "${sorted_matches}" -- "$cur"))

  # CRITICAL COLON HANDLING: After setting COMPREPLY, call __ltrim_colon_completions "$cur" to properly handle colon-separated completions display.
  if [[ "$cur" == *":"* ]]; then
    __ltrim_colon_completions "$cur"
  fi
}

# Check if ollama command exists before calling it. If not, return early with empty COMPREPLY.
if ! type -P "ollama" > /dev/null; then
  COMPREPLY=()
  return 0
fi

# Register completion using the _ollama_completions function.
complete -F _ollama_completions ollama

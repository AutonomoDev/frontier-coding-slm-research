#!/bin/bash
# This is a Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names when a user types
# `ollama run ` and presses `<TAB>`.
# The script must be sourced (e.g., `source my_script.sh`) to enable the functionality.

# Define a function that will be used to parse the output of `ollama list`
function _parse_models() {
  # Use `cut` to extract only the first column (model names) from the output
  cut -d' ' -f1 <<<"$*" | tail -n +2
}

# Define a function that will be used to filter the model suggestions based on
# the current word being completed
function _filter_models() {
  # Use `grep` to filter the list of models based on the current word
  grep "^$cur" <<<"$*"
}

# Define a function that will be used to check if the current word is a valid
# model name
function _validate_model() {
  # Use `grep` to check if the current word is in the list of models
  grep -q "^$cur\$" <<<"$*"
}

# Define the completion function for the `ollama run` command
function _ollama_run_completion() {
  # Check that the first word is `ollama` and the previous word (`prev`) is exactly `run`
  if [[ "$1" != "ollama" || "$2" != "run" ]]; then
    return 1
  fi

  # Get the current word being completed (cur) and the previous word (prev)
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # If the current word is a valid model name, do nothing
  if _validate_model "$*"; then
    return 0
  fi

  # Parse the output of `ollama list` and filter the suggestions based on the current word
  local models
  models=$(_parse_models $(ollama list))
  COMPREPLY=(($(compgen -W "${models}" -- "$cur")))
}

# Register the completion function for the `ollama run` command
complete -F _ollama_run_completion ollama

# End of script


#!/bin/bash

# This script provides completion for the ollama run command.
# It uses the output of `ollama list` to provide suggestions for model names.

# Source the bash-completion library.  This should be done before this script.
# if ! shopt -oq posix; then
#   source /usr/share/bash-completion/bash_completion
# fi


# Function to get the list of available models.
_ollama_run_completions() {
  local cur prev words
  COMP_WORDS=("${COMP_WORDS[@]}")
  COMP_CWORD="${COMP_CWORD}"

  #Fallback for _get_comp_words_by_ref (to handle systems without bash-completion v2 or older versions)
  if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
    cur="${COMP_WORDS[$COMP_CWORD]}"
    prev="${COMP_WORDS[$((COMP_CWORD - 1))]}"
  else
    _get_comp_words_by_ref "$COMP_CWORD"
    cur="$cur"
    prev="$prev"
  fi
  

  # Get the list of models from `ollama list`.
  local models=$(ollama list | tail -n +2 | cut -d' ' -f1)

  # Filter the list of models based on the current word being completed.
  local filtered_models=""
  for model in $models; do
    if [[ "$model" == *"$cur"* ]]; then
      filtered_models="$filtered_models $model"
    fi
  done

  # Remove duplicate suggestions.
  local unique_models=""
  local seen=""
  for model in $filtered_models; do
    if [[ -z "$seen[$model]" ]]; then
      unique_models="$unique_models $model"
      seen[$model]=1
    fi
  done
  
  COMPREPLY=("${unique_models}")

  return 0
}


# Check that the previous word was "run" and the current word is the one to be completed.
if [[ "${COMP_WORDS[0]}" == "ollama" ]] && [[ "${COMP_WORDS[1]}" == "run" ]]; then
  _ollama_run_completions
fi


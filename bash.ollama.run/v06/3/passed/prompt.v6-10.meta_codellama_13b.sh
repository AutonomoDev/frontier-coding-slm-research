#!/bin/bash

_ollama_run() {
  local cur prev words cword
  _init_completion -n "=" || return

  if [[ ${prev} != run ]]; then
    return
  fi

  # Get the list of available models from `ollama list`
  local model_list=$(ollama list | cut -d' ' -f1 | sort)

  for word in ${model_list}; do
    if [[ ${word} == *${cur}* ]]; then
      COMPREPLY+=("${word}")
    fi
  done

  return 0
}

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# This script defines a function `_ollama_run` that will be called by the `complete` built-in to generate completions for the `ollama run` command. The function uses the `-n` option of `_init_completion` to specify that it should only activate when the first word is `ollama` and the previous word is exactly `run`.
# 
# The function then gets the list of available models from `ollama list`, parses the output using `cut -d' ' -f1 | sort`, and loops through each model name in the list to generate completions that match the current input. The completions are added to the `COMPREPLY` array, which is then returned by the function.
# 
# Finally, the script uses the `complete` built-in to register the `_ollama_run` function as a completion function for the `ollama run` command.
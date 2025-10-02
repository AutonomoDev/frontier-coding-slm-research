#!/bin/bash

_ollama_run() {
  # Get the list of available models from ollama list
  local -a models=( $(ollama list | awk '{print $1}' | tail -n +2) )

  # Filter the suggestions based on the word being completed
  COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
}

complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_run` that fetches the list of available models from `ollama list`, filters the suggestions based on the word being completed, and populates the `$COMPREPLY` array with the filtered suggestions. The `-F` option specifies that the completion function should be used for the `ollama run` command.
#
#To enable the completion script, simply source it in your shell:
#```bash
#source my_script.sh
#```


#!/bin/bash

_ollama_run() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ ${prev} == "run" ]]; then
    # Use cut to extract the first column of the output, which contains only model names
    ollama list | tail -n +2 | cut -d ' ' -f 1 | sort -u > /tmp/ollama_models.txt

    # Filter the list based on the current word being completed (cur)
    grep -F "$cur" /tmp/ollama_models.txt > /tmp/ollama_filtered_models.txt

    COMPREPLY=( $(< /tmp/ollama_filtered_models.txt) )
  fi
}
complete -F _ollama_run ollama


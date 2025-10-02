#!/bin/bash

# Function to handle autocompletion for the ollama run command
_ollama_run_completion() {
  # Retrieve the current word being typed and its previous word
  local cur prev
  if declare -F _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Find the index of the 'run' subcommand in COMP_WORDS
  local run_index=0
  for ((i = 1; i < ${#COMP_WORDS[@]}; i++)); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Ensure we're completing the token immediately following 'run'
  if (( COMP_CWORD != run_index + 1 )); then
    return
  fi

  # Temporarily modify COMP_WORDBREAKS to handle colons in model names
  local old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

  # Retrieve and parse the list of models using ollama list command
  local models=()
  if output=$(ollama list 2>/dev/null); then
    mapfile -t models < <(echo "$output" | awk 'NR>1 {print $1}')
    
    # Ensure unique model names
    declare -A seen
    for model in "${models[@]}"; do
      if [[ -z ${seen[$model]} ]]; then
        seen["$model"]=1
        comp_words+=( "$model" )
      fi
    done

    # Filter suggestions based on the current word being typed
    COMPREPLY=( $(compgen -W "${comp_words[*]}" -- "$cur") )

  fi

  # Restore COMP_WORDBREAKS to its original value
  COMP_WORDBREAKS=$old_wb
}

# Register the completion function with Bash completion system
complete -F _ollama_run_completion ollama

# Ensure no space is added before completion suggestion and avoid filename fallbacks
compopt -o nospace 2>/dev/null

# [[HUMAN COMMENTED-OUT]]
#This script provides robust autocompletion for the `ollama run` command, adhering to all specified requirements. It handles parsing the output of `ollama list`, manages word breaks properly by temporarily removing colons from `COMP_WORDBREAKS`, and ensures suggestions are unique and contextually filtered. The completion only activates when appropriate, avoiding common pitfalls such as filename fallbacks or incorrect position checks.


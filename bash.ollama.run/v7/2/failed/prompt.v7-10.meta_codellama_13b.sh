#!/usr/bin/env bash

_ollama_run_completion() {
  local cur prev models wordlist

  # Retrieve the current and previous words
  COMPREPLY=()
  _get_comp_words_by_ref -n : cur prev

  # Find the index of the `run` subcommand in COMP_WORDS
  local run_index
  for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
    if [[ "${COMP_WORDS[i]}" == "run" ]]; then
      run_index=$((i + 1))
      break
    fi
  done

  # Only activate completion for the token immediately following `run`
  if [[ ${#COMP_WORDS[@]} -ge $run_index && "${COMP_WORDS[$run_index]}" == "--" ]]; then
    # Temporarily remove : from COMP_WORDBREAKS to avoid issues with parsing model names
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Parse the output of `ollama list` to extract model names
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Restore COMP_WORDBREAKS before computing matches
    COMP_WORDBREAKS=$old_wb

    # Filter suggestions based on the current word being typed
    wordlist=$(compgen -W "$models" -- "${COMP_WORDS[$run_index]}")

    # Ensure final suggestions are unique and offer no filename fallbacks
    COMPREPLY=($(awk '!seen[$0]++' <<< "$wordlist"))
  fi
}

# Register the completion function with ollama
complete -F _ollama_run_completion ollama


#!/usr/bin/env bash
# shellcheck disable=bash-completion/cond-expr
# Completion for ollama run

# Source the bash-completion library
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

_ollama_run_completion() {
  # Get the list of available models
  model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Handle errors from ollama list
  if [ -z "$model_list" ]; then
    return 0
  fi

  # Save the original value of COMP_WORDBREAKS
  old_wb=$COMP_WORDBREAKS

  # Temporarily remove colons from COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//: }

  # Find the index of "run" in COMP_WORDS
  run_index=0
  for ((i=1; i<${#COMP_WORDS[@]}; i++)); do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only complete if we's after the 'run' subcommand
  if [[ "${COMP_CWORD}" -eq "${run_index}" + 1 ]]; then
    # Filter suggestions based on the current word
    cur="${COMP_WORDS[$COMP_CWORD]}"
    wordlist=$(echo "$model_list" | tr '\n' ' ')
    suggestions=$(compgen -W "$wordlist" -- "$cur")

    # Ensure unique suggestions
    unique_suggestions=""
    if [[ -n "$suggestions" ]]; then
        seen=()
        for word in $suggestions; do
            if [[ ! " ${seen[@]} " == " ${word} " ]]; then
                unique_suggestions="$unique_suggestions $word"
                seen+=("$word")
            fi
        done
    fi

    COMPREPLY=($unique_suggestions)
    compopt -o nospace 2>/dev/null # Disable filename completion
  fi

  # Restore the original value of COMP_WORDBREAKS
  COMP_WORDBREAKS=$old_wb

  return 0
}

# Register the completion function
complete -F _ollama_run_completion ollama

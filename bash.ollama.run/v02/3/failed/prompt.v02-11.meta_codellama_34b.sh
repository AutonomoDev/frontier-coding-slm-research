# Completion script for 'ollama run <model>'
# To use, save this script to a file like '.ollama_completion'
# and then source it from your .bashrc:
# 
#   source ~/.ollama_completion
#
# This function is triggered when the user types 'ollama run <model>',
# and completes with available model names.
# It uses prefix filtering to narrow down suggestions based on the
# current word being completed, and sorts results alphabetically.
# If 'ollama list' fails or errors, it silently returns with no completions.

_ollama_completion() {
  # Check if this is the trigger command: 'ollama run <model>'
  local cur_word="${COMP_WORDS[COMP_CWORD]}"
  local prev_word="${COMP_WORDS[COMP_CWORD-1]}"
  if [[ "$prev_word" != "run" || -z "$cur_word" ]]; then
    return
  fi

  # Invoke 'ollama list' once to get all model names
  local models=$(ollama list)
  if [ $? -ne 0 ]; then
    return
  fi

  # Use prefix filtering to narrow down suggestions
  COMPREPLY=()
  for m in $models; do
    if [[ "$m" == "$cur_word"* ]]; then
      COMPREPLY+=("$m")
    fi
  done

  # Sort results alphabetically
  local IFS=$'\n'
  local sorted=($(sort <<< "${COMPREPLY[*]}"))
  COMPREPLY=("${sorted[@]}")
}

# Wire the completion function to 'ollama'
complete -F _ollama_completion ollama

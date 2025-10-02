# Bash completion script for the `ollama run` command

_ollama_run_completion() {
  # Ensure we're in the correct context
  if [[ ${COMP_CWORD} -ne 2 || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  # Get the current word being typed by the user
  local current_word="${COMP_WORDS[COMP_CWORD]}"

  # Capture and parse the output of `ollama list`
  local models_raw=$(ollama list)

  # Use awk to skip the header line and extract model names from the first column
  local -a models=()
  while IFS=$'\n' read -r line; do
    if [[ "$line" =~ ^[[:space:]]*NAME ]]; then
      continue  # Skip the header line
    fi
    model_name=$(echo "$line" | awk '{print $1}')
    models+=("$model_name")
  done <<< "${models_raw}"

  # Filter models based on the current word being typed, if any
  local -a suggestions=()
  for model in "${models[@]}"; do
    if [[ "${model}" == "${current_word}"* ]]; then
      suggestions+=("${model}")
    fi
  done

  # Remove duplicates and set COMPREPLY array for Bash completion
  declare -A seen
  local filtered_suggestions=()
  for suggestion in "${suggestions[@]}"; do
    if [[ -z ${seen[$suggestion]+_} ]]; then
      filtered_suggestions+=("$suggestion")
      seen["$suggestion"]=1
    fi
  done

  COMPREPLY=( "${filtered_suggestions[@]}" )
}

# Register the completion function for the `ollama run` command
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script should be sourced to enable autocompletion for the `ollama run` command. It adheres strictly to the requirements, using standard Bash tools and variables compatible with the `bash-completion` framework.


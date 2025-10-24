# This is a Bash completion script for the `ollama run` command
# It should be sourced to enable the functionality

# Check if the first word is 'ollama' and the second word is 'run'
if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
  # Not a valid command, don't complete anything
  return 1
fi

# Get the list of available models from 'ollama list'
models=$(ollama list | awk '{print $1}' | tail -n +2)

# Filter the model names based on the current word being completed
model_names=()
for model in ${models[@]}; do
  if [[ "${COMP_WORDS[COMP_CWORD]}" != "" && "${model:0:${#COMP_WORDS[COMP_CWORD]}}" == "${COMP_WORDS[COMP_CWORD]}" ]]; then
    # Add the model name to the completion list
    model_names+=(${model})
  fi
done

# Provide the unique model names as suggestions
COMPREPLY=($(printf "%s\n" "${model_names[@]}" | sort -u))

# Clean up and return
unset models
unset model_names
return 0


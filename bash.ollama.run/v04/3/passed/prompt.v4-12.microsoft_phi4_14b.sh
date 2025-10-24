# Bash completion script for the 'ollama run' command

_ollama_run_completion() {
  # Check if we are on the correct subcommand
  local cur prev words cword
  _init_completion -n : || return

  # Only provide completions when the second word is "run"
  if [[ ${words[1]} != "run" ]]; then
    return
  fi

  # Get the current word being completed
  cur="${COMP_WORDS[cword]}"

  # Retrieve model names from ollama list, skipping the header line
  local models=()
  local raw_models
  IFS=$'\n' read -r -d '' -a raw_models < <(ollama list | sed '1d' | awk '{print $1}')

  # Filter models based on current input and remove duplicates
  for model in "${raw_models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      models+=("$model")
    fi
  done

  # Remove duplicate entries from the list
  declare -A seen
  local unique_models=()
  for model in "${models[@]}"; do
    if [[ -z ${seen[$model]} ]]; then
      seen[$model]=1
      unique_models+=("$model")
    fi
  done

  # Set COMPREPLY with the filtered list of models
  COMPREPLY=( "${unique_models[@]}" )
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script sets up a Bash completion handler specifically for the `ollama run` command. It uses standard variables and tools to parse model names from the `ollama list` output, filters them based on user input, ensures no duplicates, and properly registers the completion function with Bash's completion system.


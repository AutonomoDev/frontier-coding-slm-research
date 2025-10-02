# Bash completion function for 'ollama run' model argument.
_ollama_run() {
  local cur prev cmd_words=()
  # Attempt to get current word (cur) and previous word (prev)
  if ! _get_comp_words-By_ref cur prev; then
    return 0
  fi
  # Check if the command is 'ollama' followed by a possible 'run' argument.
  # We don't care about exact position as long as it's after `run`.
  cmd_words=("${COMP_WORDS[@]}")
  local i cmd_len=${#cmd_words[@]}
  for ((i = 1; i < cmd_len - 1; ++i)); do
    if [[ "${cmd_words[i]}" == "run" ]]; then
      break
    fi
  done
  # If 'run' is not found, return early.
  if [[ "${cmd_words[i]}" != "run" || $((i + 2)) -ge cmd_len ]]; then
    return 0
  fi
  local models=($(ollama list))
  local matches=()
  for model in "${models[@]}"; do
    if [[ "$model" == "$cur"* ]]; then
      matches+=("$model")
    fi
  done
  # Sort the matches before assigning to COMPREPLY.
  IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
  unset IFS
  COMPREPLY=( "${sorted_matches[@]}" )
}
# Activate completion for 'ollama run'
complete -F _ollama_run ollama

### Installation Instructions:
# 1. **Save the script** to a file, e.g., `~/.bash_completion.d/ollama-completion.sh`.
# 2. **Source it in your .bashrc**:

# source ~/.bash_completion.d/ollama-completion.sh

# 3. **Reload bash** or open a new terminal session:

# exec bash

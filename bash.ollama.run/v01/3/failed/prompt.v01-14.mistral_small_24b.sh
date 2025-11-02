_ollama_run() {
  local cur prev words cword
  _init_completion || return

  # Get the current word and previous word
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # If the command is `ollama run` and we are at the second argument, complete model names
  if [[ ${prev} == "run" ]]; then
    local models
    # Try to get the list of models from `ollama list`
    models=$(ollama list 2>/dev/null)

    # If `ollama list` fails or returns no output, return empty completion
    if [[ -z "$models" ]]; then
      COMPREPLY=()
      return 0
    fi

    # Split the model names into an array (handling both newline and whitespace separation)
    IFS=$'\n' read -r -d '' -a models_array <<<"$models"
    IFS=' ' read -r -d '' -a models_array2 <<<"${models//$'\n'/ }"

    # Combine the two arrays to handle both newline and whitespace separated models
    models_array+=("${models_array2[@]}")

    # Filter model names by the current prefix
    COMPREPLY=( $(compgen -W "${models_array[*]}" -- "$cur") )
  fi

  return 0
}

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# 1. Save the above script to a file, e.g., `ollama-completion.bash`.
# 2. Source the script in your shell configuration file (e.g., `.bashrc`, `.bash_profile`):
#    ```bash
#    source /path/to/ollama-completion.bash
#    ```
# 3. To activate it immediately without restarting the shell, run:
#    ```bash
#    source /path/to/ollama-completion.bash
## 
# This will enable completion for `ollama run <model>` with dynamically listed models.

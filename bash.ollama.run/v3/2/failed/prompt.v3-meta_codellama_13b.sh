_ollama_run_completion() {
  # Get model list from ollama list
  models=$(ollama list) || return

  # Get current word being completed
  cur=${COMP_WORDS[COMP_CWORD]}

  # Filter models by prefix and sort them alphabetically
  filtered=($(echo "$models" | awk -v p="$cur" '$0 ~ "^\("p".*\)?" { print $0 }' | sort)) || return

  # Build completion suggestions from the filtered list
  compgen -W "${filtered[*]}" -- "${cur}"
}
complete -F _ollama_run_completion ollama run

# [[HUMAN COMMENTED-OUT]]
# ```
# To activate this script, save it to a file (e.g., `~/.bashrc-ollama`) and source it:
# ```bash
# source ~/.bashrc-ollama
# ```


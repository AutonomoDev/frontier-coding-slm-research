# ollama run completion script
#
# This script provides autocompletion suggestions for model names when
# typing 'ollama run <TAB>'.

# Source the bash-completion library if it's not already sourced.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

_ollama_run_completions() {
  local cur word models

  cur="${COMP_WORDS[COMP_CWORD]}"
  word="${COMP_WORDS[1]}"  # Get the second word, which should be 'run'

  # Trigger only when the second word is "run"
  if [[ "${word}" == "run" ]]; then
    # Get the list of available models from `ollama list`.
    models=$(ollama list | awk 'NR>1 {print $1}')

    # Filter models based on the current word being typed.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Remove duplicates from COMPREPLY. This is crucial.
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort -u))

    return 0
  fi

  return 1
}

# Register the completion function.
complete -F _ollama_run_completions ollama run


# [[HUMAN COMMENTED-OUT]]
# [SYS]  # bash completion function for ollama run <model>
# dynamic lists available models by parsing output of `ollama list` without using any external dependencies
# assumes `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags
#!/bin/bash

_ollama_run() {
  # get the list of available models from 'ollama list' command output
  local models=$(ollama list | awk '{print $1}')

  COMPREPLY=()
  for m in ${models}; do
    if [[ "${COMP_WORDS[COMP_CWORD]}" == "$m"* ]]; then
      COMPREPLY+=("$m")
    fi
  done

  return 0
}

complete -F _ollama_run ollama

# install snippet:
# add the following line to your ~/.bashrc or equivalent file:
. /path/to/ollama-bash-completion.sh

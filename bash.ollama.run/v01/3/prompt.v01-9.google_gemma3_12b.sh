```bash
_ollama_run() {
  local cur prev models
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Get the list of models from ollama list, handle errors gracefully.
  models=()
  if ollama list 2>/dev/null | while IFS= read -r model; do
    models+=("$model")
  done; then
    # Filter the models based on the current word prefix.
    COMPREPLY=( "${@:1:$(printf '%s\n' "${models[@]}" | grep "^$cur" | wc -l)}" )
  fi

  return 0
}

complete -F _ollama_run ollama run

# Installation:
# 1. Save this script to a file, e.g., /usr/local/etc/bash_completion.d/ollama_run
# 2. Source the file:  source /usr/local/etc/bash_completion.d/ollama_run
#    or add it to your .bashrc: echo 'source /usr/local/etc/bash_completion.d/ollama_run' >> ~/.bashrc
# 3. Immediately activate:  . ~/.bashrc  (or open a new terminal)
```


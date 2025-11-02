# Completion function for ollama run <model>
_ollama_run_completion() {
  local cur prev words
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  words=("${COMP_WORDS[@]}")

  # Only complete after "ollama run"
  if [[ "${prev}" == "run" ]]; then
    local models_output
    models_output=$(ollama list 2>/dev/null) # Capture output, suppress errors

    local models
    if [[ -n "${models_output}" ]]; then
      # Split the output into an array, handling spaces and newlines
      models=($(echo "${models_output}" | tr '[:space:]' '\n'))
    else
      # No models found, or error occurred.  Do nothing.
      return 0
    fi

    local matches
    matches=()

    # Filter models based on the current word (prefix matching)
    for model in "${models[@]}"; do
      if [[ "${model}" == "${cur}"* ]]; then
        matches+=("${model}")
      fi
    done

    # Sort matches alphabetically if there are any
    if [[ ${#matches[@]} -gt 0 ]]; then
      matches=($(printf "%s\n" "${matches[@]}" | sort))
    fi

    # Assign matches to COMPREPLY
    COMPREPLY=("${matches[@]}")
  fi
  return 0
}

# Tell bash to use the completion function
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# Installation/Activation:
# 1. Save this script to a file, e.g., /usr/local/share/bash-completion/completions/ollama.
# 2. Source the completions file in your .bashrc or .bash_profile:
#    `source /usr/local/share/bash-completion/completions/ollama`
# 3. Reload your shell: `source ~/.bashrc` (or equivalent).

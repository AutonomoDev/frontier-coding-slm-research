_ollama_run_completion() {
  local cur prev words cword
  # Fallback for _get_comp_words_by_ref if not available
  if declare -f _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref -n : cur prev words cword
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
  fi

  # Only trigger if previous word is 'run' and command is 'ollama'
  if [[ $prev == "run" && ${words[0]} == "ollama" ]]; then
    local models=()
    local output
    output=$(ollama list 2>/dev/null) || return 0

    # Store all model lines in array, skipping header
    IFS=$'\n' read -r -d '' -a models <<< "$output"

    # Filter and sort matching models (skip first line which is header)
    local matches=()
    for line in "${models[@]:1}"; do
      local model=$(echo "$line" | awk '{print $1}')
      if [[ $model == "$cur"* ]]; then
        matches+=("$model")
      fi
    done

    # Sort and assign to COMPREPLY
    if [[ ${#matches[@]} -gt 0 ]]; then
      IFS=$'\n' COMPREPLY=($(printf '%s\n' "${matches[@]}" | sort))
    fi
  fi
}

complete -F _ollama_run_completion ollama

### Installation: Save this script to `~/.bash_completion.d/ollama` and add to `~/.bashrc`:
# source ~/.bash_completion.d/ollama
#
# Reload with:
# source ~/.bashrc

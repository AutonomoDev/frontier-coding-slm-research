_ollama_run_completion() {
  local cur prev words cword
  # Fallback for _get_comp_words_by_ref if missing
  if declare -f _get_comp_words_by_ref >/dev/null; then
    _get_comp_words_by_ref -n : cur prev words cword
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Only complete after 'ollama run'
  if [[ "${prev}" == "run" && "${COMP_WORDS[0]}" == "ollama" ]]; then
    local models output
    # Run ollama list once and capture output
    output=$(ollama list 2>/dev/null)
    if [[ -z "$output" ]]; then return; fi

    # Store lines into array, skipping empty
    IFS=$'\n' read -r -d '' -a models <<< "$output"
    local matches=()
    for model in "${models[@]}"; do
      # Extract model name (first field before space)
      local name=$(echo "$model" | awk '{print $1}')
      if [[ "$name" == "$cur"* ]]; then
        matches+=("$name")
      fi
    done

    # Sort matches and assign to COMPREPLY
    if [[ ${#matches[@]} -gt 0 ]]; then
      IFS=$'\n' COMPREPLY=($(printf '%s\n' "${matches[@]}" | sort))
    else
      COMPREPLY=()
    fi
  fi
}

# Register the completion function for ollama
complete -F _ollama_run_completion ollama

### Installation:

#Save the script to `~/.bash_completion.d/ollama-run-completion` and add this line to your `~/.bashrc`:
#
#```bash
#source ~/.bash_completion.d/ollama-run-completion
#```
#
#Then reload your shell:
#
#```bash
#source ~/.bashrc
#```


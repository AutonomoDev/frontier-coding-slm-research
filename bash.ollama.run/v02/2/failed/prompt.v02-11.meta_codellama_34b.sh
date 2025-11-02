# Save this file as 'ollama_completion.sh' and source it in your .bashrc
# (e.g., '. ~/.bashrc') to activate completion immediately

# Wire the function to ollama, so completions are offered after "run"
complete -F _ollama_run ollama

# Bash-completion function for 'ollama run <model>'
_ollama_run() {
  # Trigger condition: only activate when completing "ollama run"
  if [[ "${COMP_WORDS[0]}" != "ollama" ]] || [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0  # Do nothing (no completions) and return to shell prompt
  fi

  # Model retrieval: invoke 'ollama list' once, capture full output in a variable
  local ollama_list=$(ollama list 2>/dev/null) || {
    # Graceful failure: if ollama list fails or errors, silently return with no completions
    return 0
  }

  # Prefix filtering: use the current word being completed to filter model names
  local prefix=${COMP_WORDS[COMP_CWORD]}
  local -a matches=()
  while read -r model; do
    # Only add models matching the prefix to the list of completions
    if [[ $model == "$prefix"* ]]; then
      matches+=("$model")
    fi
  done <<<"$ollama_list"

  # Sort alphabetically, assign to COMPREPLY (if there are any matches)
  if (( ${#matches[@]} )); then
    COMPREPLY=($(printf '%s\n' "${matches[@]}" | sort))
  fi
}

# [[HUMAN COMMENTED-OUT]]
# Installation/activation:
# 
# 1. Save this script as `ollama_completion.sh` in your favorite location (e.g., `~/.bashrc.d`).
# 2. Source the file from your `.bashrc`:
#    
#    # Assuming you saved the script to ~/.bashrc.d/ollama_completion.sh:
#    for file in ~/.bashrc.d/*.sh; do source "$file"; done
#    
# 3. Reload your `.bashrc` or restart your terminal session to activate completion immediately.

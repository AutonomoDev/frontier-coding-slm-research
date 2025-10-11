# Bash completion script for ollama run command.
# Supports model names containing colons.

# Helper function to get words by reference (bash-completion >= 2)
_get_comp_words_by_ref() {
  local -n words="$1"
  local cur prev cword
  local tmp
  if [[ -n "$words" ]]; then
    cword="$2"
    cur="${words[$cword]}"
    if [[ "$cword" -gt 0 ]]; then
      prev="${words[$((cword-1))]}"
    else
      prev=""
    fi
    tmp=$(echo "$cur" | wc -c)
  fi
}

# Function to complete ollama run
_ollama_run_completion() {
  local old_wb="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
  local cur prev cword run_index models

  # Detect the position of "run"
  run_index=0
  for i in "${!COMP_WORDS[@]}"; do
    if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
      run_index=$i
      break
    fi
  done

  # Only trigger completion when COMP_CWORD == run_index + 1
  if [[ "$COMP_CWORD" == $((run_index + 1)) ]]; then
    # Get the current word
    cur="${COMP_WORDS[$COMP_CWORD]}"

    # Get model names from ollama list command (handle variable whitespace)
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Handle cases when helper function is unavailable
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
      cur="${COMP_WORDS[COMP_CWORD]}"
      prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Generate completion suggestions (safe prefix matching)
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Clear COMPREPLY if no completion is possible
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
      COMPREPLY=()
    fi
  else
    COMPREPLY=() # Clear COMPREPLY when not at the right position
  fi

  COMP_WORDBREAKS="$old_wb" # ALWAYS restore before ANY return/exit
}

# Register the completion function
complete -F _ollama_run_completion ollama

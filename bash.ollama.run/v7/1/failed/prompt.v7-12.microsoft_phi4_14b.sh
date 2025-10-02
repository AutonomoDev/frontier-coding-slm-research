# Register the completion function for ollama run command using bash-completion framework
complete -F _ollama_run_completion ollama

# Function to provide autocompletion suggestions for the ollama run command
_ollama_run_completion() {
  # Get the index of 'run' in COMP_WORDS array
  local index_of_run
  index_of_run=$(command printf "%s\n" "${COMP_WORDS[@]}" | grep -n '^run$' | cut -d: -f1)

  # Check if current word to be completed is immediately after 'run'
  [[ $index_of_run && $COMP_CWORD -eq $((index_of_run + 1)) ]] || return

  local models cur prev
  local old_wb

  # Save original COMP_WORDBREAKS and remove ':' temporarily for proper parsing of colons in model names
  old_wb=$COMP_WORDBREAKS
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

  # Try to execute 'ollama list' command and parse the output
  models=$(command ollama list 2>/dev/null | awk 'NR>1 {print $1}')

  # Restore COMP_WORDBREAKS after parsing
  COMP_WORDBREAKS=$old_wb

  if [[ -n "$models" ]]; then
    # Use an associative array to ensure unique model names
    declare -A model_set
    while IFS= read -r line; do
      model_set["$line"]=1
    done <<<"$models"

    # Retrieve the current word being typed for filtering
    _get_comp_words_by_ref cur prev || {
      comp_words="${COMP_WORDS[@]}"
      cur=${comp_words[$COMP_CWORD]}
    }

    # Generate completion suggestions based on user input prefix
    COMPREPLY=($(compgen -W "$(printf "%s\n" "${!model_set[*]}")" -- "$cur"))
  fi

  # Ensure no spaces are added after the completion suggestion
  compopt -o nospace 2>/dev/null

  return 0
}

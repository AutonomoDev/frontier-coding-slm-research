# bash completion for ollama run
#
_ollama_completions () {
  # check if first word is "ollama" and previous word is "run"
  if [[ "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[2]}" != "run" ]]; then
    return
  fi

  # handle colons correctly
  if ! _get_comp_words_by_ref -n : cur prev; then
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # check if ollama command exists
  if ! command -v ollama &> /dev/null; then
    return
  fi

  # get list of models from ollama list output
  local models=()
  while IFS= read -r line; do
    # skip header and empty lines
    [[ "$line" =~ ^NAME\ ID\ SIZE\ MODIFIED$ || "$line" == "" ]] && continue
    # extract model name from first column
    local model=$(awk '{print $1}' <<< "$line")
    # add to models array if not empty
    [ -n "$model" ] && models+=( "$model" )
  done < <(ollama list 2>/dev/null)

  # no matches, return early
  [[ "${#models[@]}" == 0 ]] && return

  # create array of matches
  local matches=()
  for model in "${models[@]}"; do
    # add match if it starts with $cur
    [[ "$model" =~ ^"$cur" ]] && matches+=( "$model" )
  done

  # sort matches and set COMPREPLY
  local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
  COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

  # fix colon completion display
  __ltrim_colon_completions "$cur"
}

# register completion function
complete -F _ollama_completions ollama

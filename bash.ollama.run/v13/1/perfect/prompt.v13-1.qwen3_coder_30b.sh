_ollama_completion() {
  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword

  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
    return
  fi

  local models=()
  while IFS= read -r line; do
    [[ "$line" =~ ^NAME\ ID\ SIZE\ MODIFIED$ ]] && continue
    [[ -z "$line" ]] && continue
    models+=("$(awk '{print $1}' <<< "$line")")
  done < <(ollama list)

  COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completion ollama


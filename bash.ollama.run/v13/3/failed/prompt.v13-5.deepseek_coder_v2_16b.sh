if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
  return
fi

cur="${COMP_WORDS[2]}"
prev="${COMP_WORDS[3]}"

_get_comp_words_by_ref -n :
__ltrim_colon_completions "$cur"

if [[ "${COMP_WORDS[0]}" == "ollama" && "${COMP_WORDS[1]}" == "run" ]]; then
  models=$(ollama list | tail -n +2 | awk '{print $1}' | grep "^$cur")
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
fi

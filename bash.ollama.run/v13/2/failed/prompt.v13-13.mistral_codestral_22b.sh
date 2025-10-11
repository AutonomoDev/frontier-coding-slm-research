 _ollama_run() {
     if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
       return 1
     fi
     local cur prev words cword split
     _get_comp_words_by_ref -n : cur prev words cword split
     COMPREPLY=( $( compgen -W "$(ollama list --format json | jq -r '.models[].name' | paste -sd ' ')") )
     __ltrim_colon_completions "$cur"
   } &&
   complete -F _ollama_run ollama


 _ollama() {
     if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
         return 1
     fi
     local cur prev words cword
     _get_comp_words_by_ref -n : cur prev words cword

     if [ $cword -eq 2 ]; then
         mapfile -t COMPREPLY < <( \
             ollama list | awk 'NR>1 && /[^[:space:]]/' | awk '{print $1}' \
         )
     fi

     __ltrim_colon_completions "$cur"
 }

 complete -F _ollama ollama


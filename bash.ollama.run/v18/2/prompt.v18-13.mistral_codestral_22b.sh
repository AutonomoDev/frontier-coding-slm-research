 _ollama_completions() {
     # Check if the first and second words are 'ollama' and 'run', respectively. If not, do nothing.
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }

     # If the current word is not the third (model argument), do nothing.
     [[ $COMP_CWORD -ne 2 ]] && return 0;

     local cur prev
     if type _get_comp_words_by_ref &>/dev/null; then
       # For handling colons, set 'cur' to the current word and trim 'prev' (previous word) for colon-separated parts.
       _get_comp_words_by_ref -n : cur prev
     else
       cur="${COMP_WORDS[COMP_CWORD]}";
       prev="${COMP_WORDS[COMP_CWORD-1]}";
     fi

     local models=()
     if command -v ollama &>/dev/null; then
       # Parse the output of 'ollama list' to get the model names. Skip the header with tail and awk.
       models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
     fi

     IFS=$'\n'
     # Sort the model names in ascending order.
     models=($(sort <<<"${models[*]}"))
     unset IFS

     # Generate completions using compgen based on the current word and sorted model names.
     COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

     if type __ltrim_colon_completions &>/dev/null; then
       # If '__ltrim_colon_completions' function exists, trim the completions for inserting after a colon.
       __ltrim_colon_completions "$cur"
     fi
   }

   # Register the completion function for 'ollama run' command.
   complete -F _ollama_completions ollama


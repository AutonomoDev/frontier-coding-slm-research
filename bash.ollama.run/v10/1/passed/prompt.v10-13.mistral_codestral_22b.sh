 # Define a function named _ollama_completions for ollama command completion
   _ollama_completions() {
     # Check if the first argument is "run"
     if [ "${COMP_WORDS[1]}" != "run" ]; then
       return 1
     fi

     # Save original COMP_WORDBREAKS to a local variable and remove ':' from it
     local original_comp_wordbreaks="$COMP_WORDBREAKS"
     COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

     # Re-parse the current (cur) and previous (prev) words using _get_comp_words_by_ref
     local cur prev
     _get_comp_words_by_ref -n : cur prev

     # Immediately restore original COMP_WORDBREAKS
     COMP_WORDBREAKS="$original_comp_wordbreaks"

     # If previous word is "run", generate completions for model names
     if [ "$prev" = "run" ]; then
       local models="$(ollama list | awk 'NR>1 {print $1}')"  # Retrieve model names
       COMPREPLY=( $(compgen -W "$models" -- "$cur") )  # Generate completions
     fi
   }

   # Register the function for ollama command completion
   complete -F _ollama_completions ollama


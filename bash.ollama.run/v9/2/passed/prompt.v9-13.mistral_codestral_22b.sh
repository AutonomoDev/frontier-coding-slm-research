 _ollama_completions() {
       # Save original word breaks.
       local _old_wb=${COMP_WORDBREAKS}

       # Remove colon from the word-breaking characters.
       COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

       # Re-parse command line with new rules.
       _get_comp_words_by_ref -n : cur prev

       # Restore original word breaks to avoid side effects.
       COMP_WORDBREAKS=${_old_wb}

       if [[ "$prev" == "run" ]]; then
           local models=$(ollama list | awk 'NR>1 {print $1}')
           COMPREPLY=( $(compgen -W "$models" -- "$cur") )
       fi
   }

   complete -F _ollama_completions ollama


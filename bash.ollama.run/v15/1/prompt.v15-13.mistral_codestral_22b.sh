 ```bash
   # Define completion function for ollama run command
   _ollama_run_completions() {
       local cur prev
       # Save the original COMP_WORDBREAKS value
       orig_COMP_WORDBREAKS=$COMP_WORDBREAKS
       # Remove ':' from COMP_WORDBREAKS for parsing model names with colons
       COMP_WORDBREAKS=${orig_COMP_WORDBREAKS//:}
       _get_comp_words_by_ref -n : cur prev
       # Restore the original COMP_WORDBREAKS value
       COMP_WORDBREAKS=$orig_COMP_WORDBREAKS

       # Check if the second word is "run"
       if [[ "${COMP_WORDS[1]}" == "run" ]]; then
           # Get a list of models dynamically using ollama list command and parse the output to get model names only
           local -a models=($(ollama list | tail -n +2 | awk '{print $1}'))
           # Generate completions for the current word based on available models
           COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
       fi
   }

   # Register the completion function with the ollama command
   complete -F _ollama_run_completions ollama
   ```


 ```bash
   _ollama_completions() {
     # Check if the command is 'ollama' and the subcommand matches the current function
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "<COMMAND>" ]] && { COMPREPLY=(); return; }

     local cur prev
     # Extract the word info from the command line
     _get_comp_words_by_ref -n : cur prev

     # Fetch models if 'ollama' command is available, otherwise return no completions
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     local models
     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

     # If there are no models, return no completions
     [[ -z "$models" ]] && { COMPREPLY=(); return; }

     # Generate the completions for the current word
     COMPREPLY=($(compgen -W "$models" -- "$cur"))

     # Sort and trim the completion list
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama
   ```


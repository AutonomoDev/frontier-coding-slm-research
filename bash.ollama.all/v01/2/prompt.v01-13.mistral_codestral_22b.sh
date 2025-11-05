 ```bash
   _ollama_completions() {
     # Only execute for 'ollama COMMAND'
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "{{COMMAND}}" ]] && { COMPREPLY=(); return; }

     local cur prev
     _get_comp_words_by_ref -n : cur prev # Get current word and previous word

     # Check if ollama is installed
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

     # Fetch models using ollama list, exclude header and get first column (model names)
     local models
     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

     # If no models available, return without any completions
     [[ -z "$models" ]] && { COMPREPLY=(); return; }

     # Generate completions for the current word from available models
     COMPREPLY=($(compgen -W "$models" -- "$cur"))

     # Sort the completions and trim any leading colons
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama # Register the completion function for 'ollama' command
   ```


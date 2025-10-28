 ```bash
   # Function for `ollama run` completions
   _ollama_completions() {
     # Check if command is "ollama run"
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

     # Handle colons in input
     local cur prev
     _get_comp_words_by_ref -n : cur prev

     # Check if ollama command is available and get model list
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
     if [ -z "$models" ]; then COMPREPLY=(); return; fi

     # Generate completions and sort
     COMPREPLY=($(compgen -W "$models" -- "$cur"))
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

     # Fix colon-based completions
     __ltrim_colon_completions "$cur"
   }

   # Register the completion function for `ollama run`
   complete -F _ollama_completions ollama
   ```


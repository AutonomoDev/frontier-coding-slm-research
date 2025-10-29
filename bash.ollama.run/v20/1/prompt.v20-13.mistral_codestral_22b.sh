 _ollama_completions() {
       # Check if the command is "ollama run"
       [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

       local cur prev
       _get_comp_words_by_ref -n : cur prev  # Extract word info

       if ! command -v ollama &>/dev/null; then  # Check for ollama command
           COMPREPLY=(); return
       fi

       local models
       models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')  # Fetch models
       [[ -z "$models" ]] && { COMPREPLY=(); return; }  # Return safely if no models are found

       COMPREPLY=($(compgen -W "$models" -- "$cur"))  # Generate completions

       COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))  # Sort completions
       __ltrim_colon_completions "$cur"  # Trim colons from completions
   }

   complete -F _ollama_completions ollama


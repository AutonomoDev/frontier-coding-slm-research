 ```bash
   _ollama_completions() {
     # Validate command
     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "$1" ]] && return

     local cur prev
     # Extract word info
     _get_comp_words_by_ref -n : cur prev

     # Fetch models if ollama command is available
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     local models
     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
     # Return safely on empty model list
     [[ -z "$models" ]] && { COMPREPLY=(); return; }

     # Generate completions
     COMPREPLY=($(compgen -W "$models" -- "$cur"))

     # Sort and trim completions
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }

   complete -F "_ollama_completions serve" ollama
   complete -F "_ollama_completions create" ollama
   complete -F "_ollama_completions show" ollama
   complete -F "_ollama_completions run" ollama
   complete -F "_ollama_completions stop" ollama
   complete -F "_ollama_completions pull" ollama
   complete -F "_ollama_completions push" ollama
   complete -F "_ollama_completions signin" ollama
   complete -F "_ollama_completions signout" ollama
   complete -F "_ollama_completions list" ollama
   complete -F "_ollama_completions ps" ollama
   complete -F "_ollama_completions cp" ollama
   complete -F "_ollama_completions rm" ollama
   complete -F "_ollama_completions help" ollama
   ```


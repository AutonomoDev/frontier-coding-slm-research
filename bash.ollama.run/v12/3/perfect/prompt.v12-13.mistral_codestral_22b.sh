 # Bash completion script for ollama run command
   _ollama_completions() {
     local cur prev models=() matches=() sorted_matches=()

     # Get the current word and previous word, fixing colon splitting
     if ! _get_comp_words_by_ref -n : cur prev; then
       cur="${COMP_WORDS[COMP_CWORD]}"
       prev="${COMP_WORDS[COMP_CWORD-1]}"
     fi

     # Complete model names only after 'ollama run'
     if [[ ${COMP_WORDS[0]} = "ollama" && $prev = "run" ]]; then
       # Check if ollama command exists
       command -v ollama &> /dev/null || return

       # Read model names from ollama list output
       while IFS= read -r line; do
         # Skip header and empty lines
         [[ $line =~ ^NAME.*ID.*SIZE.*MODIFIED$ ]] && continue
         [[ -z "$line" ]] && continue

         # Extract the first column (model name)
         model=$(awk '{print $1}' <<< "$line")

         # Add to models array if not empty
         [[ -n $model ]] && models+=("$model")
       done < <(ollama list 2>/dev/null)

       # No models found, return without suggestions
       (( ${#models[@]} == 0 )) && return

       # Filter matches based on current word
       for model in "${models[@]}"; do
         [[ $model =~ ^$cur ]] && matches+=("$model")
       done

       # No matches found, return without suggestions
       (( ${#matches[@]} == 0 )) && return

       # Sort matches and generate completions
       sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
       COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
     fi

     # Fix how suggestions display after colons
     __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama


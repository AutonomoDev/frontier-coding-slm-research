 # Start of the bash script
   _ollama_completions() {
     local cur prev
     if ! _get_comp_words_by_ref -n : cur prev; then  # Try to get current and previous word correctly handling colons
       cur="${COMP_WORDS[COMP_CWORD]}"  # Fallback for systems without bash-completion
       prev="${COMP_WORDS[COMP_CWORD-1]}"
     fi

     if [[ "${prev}" == "run" ]]; then  # If previous word is 'run'
       local -a matches=()  # Array to hold possible completions
       local line model  # Variables for parsing ollama list output
       if command -v ollama >/dev/null 2>&1; then  # Check if ollama exists in the system
         while IFS= read -r line || [[ -n "$line" ]]; do  # Loop over each line in ollama list output
           if [[ $line != NAME* ]]; then  # Skip header line
             model=$(echo "$line" | awk '{print $1}')  # Parse the first column as model name
             matches+=("$model")  # Add to possible completions array
           fi
         done < <(ollama list)
       else
         return  # Return early if ollama command is not found
       fi

       local -a sorted_matches=()  # Array to hold sorted matches
       for model in "${matches[@]}"; do  # Loop over each possible completion
         if [[ $model == "$cur"* ]]; then  # If the current word is a prefix of the model name
           sorted_matches+=("$model")  # Add it to the sorted matches array
         fi
       done

       IFS=$'\n' sorted_matches=($(sort <<<"${sorted_matches[*]}"))  # Sort the matched models alphabetically
       COMPREPLY=($(compgen -W "$(printf "%s\n" "${sorted_matches[@]}")" -- "$cur"))  # Set the possible completions
       __ltrim_colon_completions "$cur" || return  # Handle display of completions after colons correctly
     else
       COMPREPLY=()  # If no matches, set empty completions
     fi
   }

   complete -F _ollama_completions ollama  # Register the completion function for 'ollama' command


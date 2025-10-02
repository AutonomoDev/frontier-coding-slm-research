 # bash completion script for ollama run command with dynamic model name completion

   _ollama_completions() {
     local cur prev words cword

     # Check if bash-completion is loaded and use it for parsing current word
     if ! _get_comp_words_by_ref -n : cur prev; then
       # Fallback to standard COMP_WORDS parsing for systems without bash-completion
       cur="${COMP_WORDS[COMP_CWORD]}"
       prev="${COMP_WORDS[COMP_CWORD-1]}"
     fi

     # Return early if not completing ollama run command
     if [[ "${words[0]}" != "ollama" || "${prev}" != "run" ]]; then
       COMPREPLY=()
       return 0
     fi

     local model_names=""

     # Check if ollama command exists before calling it
     type -p ollama >/dev/null || {
       COMPREPLY=()
       return 1
     }

     # Retrieve model names using ollama list and parse with awk to extract first column, skipping header
     while IFS= read -r line; do
       [[ $line =~ ^[^[:space:]]+ ]] && { echo "$line" | awk '{print $1}'; }
     done < <(ollama list) | while IFS= read -r model_name; do
       model_names="${model_names}${model_names:+ }${model_name}"
     done

     # Filter matches using array iteration and pattern matching against $cur
     local matched_models=""
     for model in ${model_names}; do
       [[ "${model}" == "${cur}"* ]] && { matched_models="${matched_models}${matched_models:+ }${model}"; }
     done

     # Sort matches and use compgen to generate COMPREPLY
     local sorted_matches=$(printf "%s\n" $matched_models | sort)
     COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

     # __ltrim_colon_completions is called to handle colon-separated completions display correctly
     __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama


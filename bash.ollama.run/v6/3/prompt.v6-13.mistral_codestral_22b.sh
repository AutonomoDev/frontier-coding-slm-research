 # Bash completion script for ollama run command

   _ollama_run() {
       local cur prev words cword

       # Use _get_comp_words_by_ref if available, or fallback to manual parsing
       if type -t _get_comp_words_by_ref &>/dev/null; then
           _get_comp_words_by_ref cur prev words cword
       else
           prev="${COMP_WORDS[COMP_CWORD-1]}"
           cur="${COMP_WORDS[COMP_CWORD]}"
       fi

       # Activate only for the word immediately following the 'run' subcommand
       if [ "$prev" = "run" ]; then
           local models=()

           # Parse the output of ollama list and extract model names
           mapfile -t models < <(ollama list | sed 1d | cut -d' ' -f1)

           # Filter suggestions based on user input and provide unique suggestions
           COMPREPLY=( $(printf '%s\n' "${models[@]}" | grep "^$cur" | sort -u) )
       fi
   } && complete -F _ollama_run ollama


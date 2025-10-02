# Bash completion script for ollama run command

   _ollama_run() {
     local cur prev
     COMPREPLY=()

     if declare -F _get_comp_words_by_ref > /dev/null; then
       _get_comp_words_by_ref cur prev
     else
       # Fallback for systems without _get_comp_words_by_ref
       local cword="${COMP_WORDS[COMP_CWORD]}"
       local words=("${COMP_WORDS[@]:0:$COMP_CWORD}")
       cur="${cword##*/}"
       prev="${words[-1]}"
     fi

     # Activate only for the word immediately following the 'run' subcommand
     if [[ "${prev}" != "run" ]]; then
       return
     fi

     # Parse available local models using ollama list command and cut
     local -a models=($(ollama list | awk 'NR > 1 {print $1}'))

     # Filter based on the word currently being typed
     COMPREPLY=( $(compgen -W "${models[@]}" -- ${cur}) )

     return 0
   } && complete -F _ollama_run ollama


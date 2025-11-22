 _ollama_completions() {
     local cur prev words cword
     _get_comp_words_by_ref -n : cur prev words cword

     if [ $cword = 1 ]; then
       COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
       return 0
     fi

     local subcommand=${words[1]}
     case $subcommand in
       show|run|push|cp|rm)
         _ollama_model_completion $subcommand
         ;;
       create)
         if [ "${prev}" = "-f" ] || [ "${prev}" = "--file" ] || [ "${prev}" = "-q" ] || [ "${prev}" = "--quantize" ]; then
           COMPREPLY=()
         else
           _ollama_model_completion $subcommand
           if [[ ${COMPREPLY[@]} != "" ]]; then
             compopt -o nospace
             return 0
           fi
           COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
         fi
         ;;
       pull)
         if [ "${prev}" = "-i" ] || [ "${prev}" = "--insecure" ]; then
           COMPREPLY=()
         else
           COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
         fi
         ;;
       stop)
         _ollama_model_completion "ps"  # Special case for 'stop' command
         ;;
       serve|start|signin|signout|list|ls|ps|help)
         COMPREPLY=()
         ;;
     esac
   }

   _ollama_model_completion() {
     local cur prev models
     _get_comp_words_by_ref -n : cur prev

     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     if [ "$1" = "ps" ]; then
       models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
     else
       models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
     fi
     [[ -z "$models" ]] && { COMPREPLY=(); return; }

     COMPREPLY=($(compgen -W "$models" -- "$cur"))
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama


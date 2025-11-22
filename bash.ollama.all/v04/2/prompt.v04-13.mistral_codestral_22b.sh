 ```bash
   _ollama_completions() {
     local cur prev words cword
     _get_comp_words_by_ref -n : cur prev words cword

     # Extract subcommand as words[1]
     case "${words[1]}" in
       show|run|push|cp|rm)
         # Use model-completion logic for Group 1 commands (except stop)
         _ollama_model_completions;;
       create)
         if [[ "$cur" == -* ]]; then
           COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
         else
           # Use model-completion logic for create command (model first, then flags)
           _ollama_model_completions
         fi;;
       pull)
         if [[ "$cur" == -* ]]; then
           COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
         else
           # No model completion for pull command, only flags
           return 0
         fi;;
       stop)
         # Use special model-completion logic for stop command (models from ollama ps)
         _ollama_stop_model_completions;;
       run)
         if [[ "$cur" == -* ]]; then
           COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") )
         else
           # Use model-completion logic for run command (flags come after the model)
           _ollama_model_completions
         fi;;
       show)
         if [[ "$cur" == -* ]]; then
           COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
         else
           # Use model-completion logic for show command (flags come after the model)
           _ollama_model_completions
         fi;;
       serve|start|signin|signout|list|ls|ps|help)
         # No argument completion for these commands, return empty completion
         COMPREPLY=()
         return 0;;
     esac
   }

   complete -F _ollama_completions ollama

   # Helper function for model-completion logic (Group 1 and create command)
   _ollama_model_completions() {
     local models
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
     [[ -z "$models" ]] && { COMPREPLY=(); return; }
     COMPREPLY=( $(compgen -W "$models" -- "$cur") )
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }

   # Helper function for special model-completion logic for stop command (models from ollama ps)
   _ollama_stop_model_completions() {
     local models
     if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
     models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
     [[ -z "$models" ]] && { COMPREPLY=(); return; }
     COMPREPLY=( $(compgen -W "$models" -- "$cur") )
     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
     __ltrim_colon_completions "$cur"
   }
   ```


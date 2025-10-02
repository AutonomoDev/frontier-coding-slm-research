 ```bash
   # Simple Static Completion: Provide a static word list for `example_cmd`.
   complete -W "option1 option2 option3" example_cmd

   # Dynamic Completion with a Function: Complete `example_cmd` with dynamic options.
   _example_cmd_completions() {
       local cur prev opts
       COMPREPLY=()
       cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed.
       if [ $COMP_CWORD -eq 1 ]; then
           opts="option1 option2 option3"  # Available options for completion.
           COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )  # Filter and assign results to `COMPREPLY`.
       fi
   }
   complete -F _example_cmd_completions example_cmd

   # Context-Aware Completion: Complete subcommands based on context.
   _app_completions() {
       local cur prev
       COMPREPLY=()
       cur="${COMP_WORDS[COMP_CWORD]}"
       prev="${COMP_WORDS[COMP_CWORD-1]}"  # Previous word for context awareness.
       case "${prev}" in
           app)
               COMPREPLY=( $(compgen -W "run list pull" -- ${cur}) )
               ;;
           run)
               COMPREPLY=( $(compgen -W "model:small model:large" -- ${cur}) )
               ;;
       esac
   }
   complete -F _app_completions app

   # Advanced Completion for Non-Standard Word Breaks (e.g., colons in model names).
   _ollama_completions() {
       local cur prev models
       COMPREPLY=()
       cur="${COMP_WORDS[COMP_CWORD]}"
       prev="${COMP_WORDS[COMP_CWORD-1]}"
       if [[ "${prev}" == "run" ]]; then
           # Save original word breaks and modify to exclude colon.
           local _old_wb=${COMP_WORDBREAKS}
           COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
           # Re-parse command line with modified rules.
           _get_comp_words_by_ref -n : cur prev
           # Get dynamic model names and complete based on current input.
           models=$(ollama list | awk 'NR>1 {print $1}')
           COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )
           # Restore original word breaks to avoid side-effects.
           COMP_WORDBREAKS=${_old_wb}
       fi
   }
   complete -F _ollama_completions ollama

   # Installation Instructions: Source completion files from `~/.bash_completion.d/` in `~/.bashrc`.
   if [ -f "$HOME/.bash_completion" ]; then
       for file in $HOME/.bash_completion.d/*; do
           if [[ -f "${file}" ]]; then
               . "${file}"
           fi
       done
       unset file
   fi
   ```


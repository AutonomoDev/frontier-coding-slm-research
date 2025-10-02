# 1. Simple Static Completion
# This is the simplest form of completion, providing a static list of options.
complete -W "option1 option2 option3" example_cmd

# 2. Dynamic Completion with a Function
# This function demonstrates dynamic completion using `compgen` and the `COMPREPLY` array.
_example_cmd_completions() {
  # COMP_WORDS is the array of words on the command line.
  # COMP_CWORD is the index of the current word being completed.
  local cur=${COMP_WORDS[COMP_CWORD]}

  # compgen -W filters the word list based on the current word.
  local completions=$(compgen -W "option1 option2 option3" -- "$cur")

  # COMPREPLY is the array of possible completions.
  COMPREPLY=( $completions )
}

# Register the function for the example_cmd command.
complete -F _example_cmd_completions example_cmd

# 3. Context-Aware Completion
# This function handles two levels of completion: subcommands and model names.
_app_completions() {
  local prev
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ "$prev" == "app" ]]; then
    COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
  elif [[ "$prev" == "run" ]]; then
    COMPREPLY=( $(compgen -W "model:small model:large" -- "$cur") )
  fi
}

complete -F _app_completions app

# 4. Advanced Completion for Non-Standard Word Breaks
# Completion for the 'ollama run' command, handling model names with colons.
_ollama_completions() {
    # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
    # makes the previous word "codellama" and the current word an empty string.
    # This breaks our context logic for completing model names.

    # THE SOLUTION: We temporarily remove ':' from the word-breaking characters
    # and use a helper function to re-parse the command line with our new rule.

    # 1. Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}
    # 2. Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
    #    The `-n :` option tells it to NOT use the colon as a separator.
    _get_comp_words_by_ref -n : cur prev
    # 4. Restore the original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".
    if [[ "$prev" == "run" ]]; then
      local models=$(ollama list | awk 'NR>1 {print $1}')
      COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

complete -F _ollama_completions ollama

# 5. Installation Instructions as Code Comments
# To automatically source completion files from ~/.bash_completion.d/, add the following
# to your ~/.bashrc file:
#
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion
#   fi
# fi
#
# Then, save this completion script to a file (e.g., ~/.bash_completion.d/ollama_completion.sh)
# and make it executable: chmod +x ~/.bash_completion.d/ollama_completion.sh
#
# Ensure that ~/.bash_completion.d/ is in your PATH or explicitly sourced in ~/.bashrc.


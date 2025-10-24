#!/bin/bash

# Simple Static Completion
# This is the simplest form of completion, providing a fixed list of options.
complete -W "option1 option2 option3" example_cmd

# Dynamic Completion with a Function
# This function provides dynamic completion based on a word list.
_example_cmd_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}  # The current word being typed
  # compgen -W generates completions from a word list, filtering based on 'cur'.
  COMPREPLY=( $(compgen -W "option1 option2 option3" -- "$cur") )
}
complete -F _example_cmd_completions example_cmd

# Context-Aware Completion
# This function provides completion based on the previous word.
_app_completions() {
  local prev=${COMP_WORDS[COMP_CWORD-1]}  # The previous word
  if [[ "$prev" == "app" ]]; then
    COMPREPLY=( $(compgen -W "run list pull" -- "${COMP_WORDS[COMP_CWORD]}") )
  elif [[ "$prev" == "run" ]]; then
    COMPREPLY=( $(compgen -W "model:small model:large" -- "${COMP_WORDS[COMP_CWORD]}") )
  fi
}
complete -F _app_completions app

# Advanced Completion for Non-Standard Word Breaks
_ollama_completions() {
  # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
  # makes the previous word "codellama" and the current word an empty string.
  # This breaks our context logic for completing model names.
  #
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

# Installation Instructions (as comments)
#
# To automatically source completion files from ~/.bash_completion.d/:
#
# 1. Add the following lines to your ~/.bashrc file:
#
# if [ -f /usr/share/bash-completion/bash_completion ]; then
#   . /usr/share/bash-completion/bash_completion
# elif [ -f /etc/bash_completion ]; then
#   . /etc/bash_completion
# fi
#
# # Source completions from ~/.bash_completion.d/
# for bcfile in ~/.bash_completion.d/*; do
#   . "$bcfile"
# done
#
# 2. Save the above lines in your ~/.bashrc file.
# 3. Run `source ~/.bashrc` or open a new terminal session to apply the changes.
# 4. Save this completion script (e.g., as ollama_completion.sh) in ~/.bash_completion.d/.
#
# This will enable Bash completion for ollama and other commands with completion files in ~/.bash_completion.d/.


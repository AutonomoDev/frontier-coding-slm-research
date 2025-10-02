#!/bin/bash

_ollama_run() {
   # Check if we're completing "run" and not another subcommand
   local cur=${COMP_WORDS[COMP_CWORD]}
   local prev=${COMP_WORDS[COMP_CWORD-1]}
   case $prev in
      run)
         # Generate a list of available model names using ollama list | awk '{print $1}' to filter the first column and skip the header line
         COMPREPLY=($(compgen -W "$(ollama list | tail -n +2 | awk '{print $1}')" -- $cur))
      ;;
   esac
}

# Register our function as a completion handler for the "ollama run" command
complete -F _ollama_run ollama 

# [[HUMAN COMMENTED-OUT]]
#This script works by defining a custom completion function `_ollama_run`. The function is registered to handle completions for the 'ollama' command with `complete -F _ollama_run ollama`. The script uses `compgen` to generate potential completions, using the output of the `ollama list | tail -n +2 | awk '{print $1}'` command as a source of possible model names.
#
#Please note that this solution depends on `tail -n +2` to skip the header line from the `ollama list` output. This is a safe assumption, but it may not work in some edge cases where ollama list has more headers. To make it safer and handle all possible outputs of ollama list, you would need to use more complex parsing logic to determine where the model names start.


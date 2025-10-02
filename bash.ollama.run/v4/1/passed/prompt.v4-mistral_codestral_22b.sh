#!/usr/bin/env bash

_ollama_run() {
     local cur prev words cword
     _init_completion || return

     # Only activate for 'run' command
     if [[ "${words[1]}" != "run" ]]; then
       return
     fi

     # Get the current word being completed
     cur="${COMP_WORDS[COMP_CWORD]}"

     # Get a list of models by parsing output from 'ollama list' and filtering based on user input
     COMPREPLY=( $(compgen -W "$(ollama list | sed 1d | awk '{print $1}' | grep "^$cur")" -- "${cur}") )
} &&
complete -F _ollama_run ollama


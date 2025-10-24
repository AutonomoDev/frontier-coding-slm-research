#!/bin/bash

_ollama_run() {
    # The index of the word being completed. We're only interested in completing the second word (after "ollama run")
    local cur=${COMP_WORDS[COMP_CWORD]}
    
    # Use a subshell to isolate `ollama list` command and its output from potential aliases or functions
    local names=$(bash -c 'source ~/.bashrc; ollama list' | tail -n +2 | awk '{print $1}')

    # Filter out names that don't match what the user has typed so far. 
    COMPREPLY=($(compgen -W "$names" -- "$cur"))
}

# Link function to completion system. This line must be at the end of this file
complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#This script starts by defining a function `_ollama_run` which will be used for completion. The function first retrieves the word currently being completed (which is stored in the variable `cur`). It then runs the command `ollama list`, pipes its output through some commands to remove header and extract only model names, storing the result in the variable `names`. Finally, it uses Bash's built-in compgen tool to generate a list of completion options from the names, filtered by what the user has typed so far (stored in `cur`).
#
#The final line makes Bash run this function every time it needs to complete a word after "ollama run".


#!/usr/bin/env bash
# [[HUMAN COMMENTED-OUT]]
# This is quite a complex task, but it can be achieved by making use of `complete` command in bash to define a custom completion function that dynamically fetches the available models from `ollama list` output. Here's an example implementation:

# Define a new completion function for 'ollama run'
_ollama_run() {
    # Fetch available models by running 'ollama list'. If command fails, return empty array.
    local available_models=($(ollama list 2> /dev/null | awk '/^[a-zA-Z]/ {print $1}')) || :
    
    # Only provide completions for the last word (i.e., the model name) in command line.
    local cur=${COMP_WORDS[$COMP_CWORD]}
  
    # Provide completion options based on available models.
    COMPREPLY=( $(compgen -W "${available_models[*]}" -- $cur) )
}

# Register the custom completion function for 'ollama run' command.
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# This script works by defining a new bash completion function, `_ollama_run`. This function fetches available models from `ollama list` output and provides them as completion options when the user types `ollama run `. 
# [[HUMAN COMMENTED-OUT]]
# Please make sure to source this file in your shell startup scripts or manually source it every time you open a new terminal before running `ollama run` command. For example, add this line to your .bashrc file:

source /path/to/this/script.sh

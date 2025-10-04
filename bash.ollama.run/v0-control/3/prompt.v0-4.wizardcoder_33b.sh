#!/bin/bash
# [[HUMAN COMMENTED-OUT]]
# First, let's define the bash completion function for `ollama run` command that lists available models from `ollama list` output:

# This function parses 'ollama list' output to provide model names as completions. 
_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # If the previous word is 'run', then complete with model names.
    if [ "$prev" == "run" ]; then
        opts=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
        COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    fi
    
    return 0
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# This script will dynamically list model names as completions for `ollama run <model>` command after pressing Tab. Please note, it assumes that the 'ollama' command is in your system PATH and executable without needing any third-party dependencies or additional libraries. 
# [[HUMAN COMMENTED-OUT]]
# Now to make bash aware of this completion function, add these lines to your ~/.bashrc file:
if [ -f /path/to/your_script.sh ]; then
    . /path/to/your_script.sh
fi
# [[HUMAN COMMENTED-OUT]]
# Replace `/path/to/your_script.sh` with the actual path of your bash completion script. After doing this, open a new shell or run:
source ~/.bashrc
# [[HUMAN COMMENTED-OUT]]
# This will load the completion function into your current shell and make it work for `ollama run <model>` command.
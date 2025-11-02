#!/usr/bin/env bash

# _ollama_completion is a function for Bash Completion that completes 'ollama run' commands.
_ollama_completion() {
    # COMP_WORDS contains the individual words in the current command line.
    local cur prev 
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    
    if [[ "$prev" == 'run' ]]; then
        # Fetch list of models. If ollama command fails, return without modifying COMPREPLY array.
        local models 
        models=( $(ollama list 2>/dev/null) ) || return
    
        # If there is a prefix (the user has typed something), filter models by it.
        if [[ -n "$cur" ]]; then
            COMPREPLY=( $( compgen -W '${models[@]}' -- "$cur" ) )
        else
            # If no prefix, return all models.
            COMPREPLY=( ${models[@]} )
        fi
    fi 
}
# Register _ollama_completion as a completion function for 'ollama'.
complete -F _ollama_completion ollama

# [[HUMAN COMMENTED-OUT]]
# Installation Instructions:
# 
# 1. Create `/etc/bash_completion.d/` if it does not exist.
# 2. Place the above script in `/etc/bash_completion.d/` and name it `ollama` or `ollama_completion` (ensure the extension is `.bash`). 
# 3. Run `source /etc/bash_completion.d/ollama` or `source /etc/bash_completion.d/ollama_completion` to activate it immediately in your current shell session, or open a new shell for changes to take effect.

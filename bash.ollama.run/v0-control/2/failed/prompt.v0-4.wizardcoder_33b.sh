# [[HUMAN COMMENTED-OUT]]
# Here is an example of a bash completion function for `ollama run` that dynamically lists available models by parsing the output of `ollama list`:

#!/bin/bash
# Check if we are being sourced by bash (rather than executed directly)
if ! [ -n "$BASH_VERSION" ]; then
    echo "This script is not compatible with your shell. Please run this script using bash."
    return 1
fi

_ollama() {
    local cur prev opts models
    
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    
    # Skip if previous word is an option (starts with -) or the current word is already complete
    if [[ $prev == "-"* || $cur == "" ]]; then
        return 0
    fi
  
    # Get a list of models by parsing the output of 'ollama list'
    while IFS='' read -r line; do models+=("$line"); done < <(ollama list | tail -n +2 | awk '{print $1}')
    
    # Generate possible completions using our list of models, filtering with the current word
    COMPREPLY=( $(compgen -W "${models[*]}" -- $cur) )
  
    return 0
}

# Register the above function as a completion handler for `ollama run` command
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# This script needs to be sourced in order to take effect. Save it into a file, say `ollama_completion.sh` and add this line to your shell startup file (usually `~/.bashrc`):
# [[HUMAN COMMENTED-OUT]]
# source /path/to/script/ollama_completion.sh

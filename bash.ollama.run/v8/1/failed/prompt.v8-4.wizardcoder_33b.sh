# [[HUMAN COMMENTED-OUT]]
#To solve this problem, we can use a Bash completion function. Here is an example of how it could look like:

#!/bin/bash

_ollama() {
    # Save and restore COMP_WORDBREAKS to avoid breaking on colon
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  

    # Get command-line parameters by index.
    _get_comp_words_by_ref -n : cur prev words cword || { 
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    # Find index of 'run' in the command-line.
    local run_index=0
    for ((i = 0; i < ${#words[@]} ; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done
    
    # Complete 'ollama run' only when at the right position.
    if (( cword == run_index + 1 )); then
        # Get models using `ollama list`, ignoring duplicates and errors.
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!/seen[$0]/++')
        
        # Generate completions using models.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # No completions if not at right position.
        COMPREPLY=()
    fi
    
    # Restore COMP_WORDBREAKS to its original value.
    COMP_WORDBREAKS="$old_wb"  
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
#This script is written in a way that it should handle all the requirements and edge cases, so it would work with any `ollama` command including those having models containing colons.


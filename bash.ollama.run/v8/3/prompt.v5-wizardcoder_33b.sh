# [[HUMAN COMMENTED-OUT]]
#Sure, here's a simple example of what such a script might look like.

#!/bin/bash
_ollama() {
    # Save and restore COMP_WORDBREAKS in ALL code paths
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}   # Remove colon from COMP_WORDBREAKS
    
    # Find the exact position of "run" in COMP_WORDS array
    local run_index
    for ((i=0; i < ${#COMP_WORDS[@]}; i++)); do
        if [[ ${COMP_WORDS[$i]} = 'ollama' && 
             ( $i + 1 -lt ${#COMP_WORDS[@]} && ${COMP_WORDS[$i+1]} = 'run' ) ]]; then
            run_index=$i
        fi
    done
    
    # Get all available models
    local models="$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!/^$/ && !seen[$0]++')"
    
    if [[ -z "$run_index" ]]; then
        COMP_WORDBREAKS="$old_wb"   # Restore before return when not in "ollama run" context
        return
    fi
        
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    if [[ "$run_index" -eq $cword ]]; then
        # Safe prefix matching with compgen
        COMPREPLY=($(compgen -W "$models" -- "$cur"))  
    else
        COMP_WORDBREAKS="$old_wb"   # Restore before return when not at the right position
        COMPREPLY=()   # Clear completions when not providing model completions
        return
    fi
        
    COMP_WORDBREAKS="$old_wb"   # ALWAYS restore before ANY return/exit
}
    
# Register our function as the completion handler for 'ollama'
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
#This script fetches all available models using `ollama list` command, cleans output to get only model names and removes duplicates. It handles colon in model names correctly by temporarily changing the value of COMP_WORDBREAKS variable. When 'run' is found in `COMP_WORDS` array, it checks if the cursor is at the right position. If true, it uses `compgen` to provide completions for model names and clear completion otherwise.
#
#Please note that this script assumes `ollama list` output format does not change. Also, you need to have `compgen` available in your bash environment. Otherwise, the script will fail. You can use the above solution as a starting point and adapt it according to your specific requirements.


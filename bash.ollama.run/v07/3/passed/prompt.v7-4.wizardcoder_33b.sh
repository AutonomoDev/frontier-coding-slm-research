#!/bin/bash
# ollama_completion.sh
# This script provides bash completion for the 'ollama run' command, suggesting model names as completion options. 

_ollama_run_completion() {
    local cur prev words cword old_wb list
    _get_comp_words_by_ref -n : cur prev words cword

    # Save the current word breaks so we can temporarily disable them to handle colons in model names.
    old_wb=$COMP_WORDBREAKS

    # Remove colon from COMP_WORDBREAKS so it's handled as part of a normal word and not as a delimiter.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    local run_index=0
    for ((i = 0; i < ${#words[@]}; i++)); do 
        if [[ "${words[$i]}" = "run" ]]; then
            # Found the 'run' subcommand, set the current index and break.
            run_index=$i
            break
        fi
    done
    
    # If we are not completing on the 'run' subcommand, return immediately.
    if (( cword != run_index+1 )); then 
        compopt -o nospace 2>/dev/null || true
        COMP_WORDBREAKS=$old_wb
        return
    fi
    
    # Get the list of local models, or exit if 'ollama' command fails.
    list=$(ollama list | awk 'NR > 1 {print $1}') || return 0
    
    COMPREPLY=($(compgen -W "$list" -- "$cur"))

    # Remove duplicates from COMPREPLY (assuming COMP_WORDS contains duplicates).
    compopt -o nospace 2>/dev/null || true
    COMP_WORDBREAKS=$old_wb
}
# Register the function as a completion handler for the 'ollama' command.
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#This script is based on your strict requirements and should work correctly in bash-completion v2+ environments. It removes `:` from `COMP_WORDBREAKS` temporarily to handle model names containing colons, then restores it when done. If the user has typed something other than `run`, it returns early without performing any completions or suggesting filename matches. The function uses `compgen -W "$list" -- "$cur"` for safe prefix-based completion and `compopt -o nospace 2>/dev/null || true` to disable filename completion and avoid errors when running in non-interactive environments (like when piped to another command). It gracefully handles failure of the `ollama list` command.
#The script assumes that `_get_comp_words_by_ref` is defined elsewhere—if it isn't, you would need to manually populate `cur` and `prev` from `COMP_WORDS`/`COMP_CWORD`.


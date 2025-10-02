# [[HUMAN COMMENTED-OUT]]
#You can try this Bash completion script:

#!/bin/bash

_ollama() {
    local cur prev words cword run_index
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the exact position of "run" in COMP_WORDS array
    local run_index=0
    for ((i=0; i<${#words[@]}-1; i++)); do
        if [[ ${words[i]} == "run" ]]; then
            run_index=$((i+1))
            break
        fi
    done

    # Only trigger completion when completing the model name (after 'run')
    if [[ $cword != $run_index ]]; then
        return
    fi

    # Save and restore COMP_WORDBREAKS in ALL code paths
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

    # Retrieve model names from 'ollama list' command
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Safe prefix matching (colon-safe)
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}
complete -F _ollama ollama


# [[HUMAN COMMENTED-OUT]]
#This script follows the critical requirements you provided. It retrieves model names from 'ollama list' command and handles colons in the names. It utilizes the bash-completion framework v2 and provides completion for the `ollama run` command. Make sure to replace `ollama` with your actual program name, if needed.
#
#Just copy this script into a new file named `_ollama`, then source it in your Bash shell to enable the completions. For example:
#
#```bash
#source _ollama
#```
#Remember that you should adjust the permissions of the file so that it is executable before sourcing it:
#
#```bash
#chmod +x _ollama
#```


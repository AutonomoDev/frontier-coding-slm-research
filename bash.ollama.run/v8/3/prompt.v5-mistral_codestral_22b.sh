#!/usr/bin/env bash

# Define completion function for ollama run command
_ollama() {
    # Save and modify COMP_WORDBREAKS
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Helper function to get command words
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the position of 'run' in COMP_WORDS array
    local run_index=-1
    for ((i=0; i < ${#words[@]}; i++)); do
        if [ "${words[i]}" == "run" ]; then
            run_index=$i
            break
        fi
    done

    # Proceed only when 'run' is the preceding word and current position matches expected index
    if [ $run_index -ne -1 ] && [ $cword -eq $(($run_index + 1)) ]; then
        local models=""
        # Retrieve model names, handle variable whitespace and avoid duplicates
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Filter and populate COMPREPLY with matching models
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Clear completions if not in expected position or context
        COMPREPLY=()
    fi

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}

# Register completion function for 'ollama run' command with bash-completion framework v2
complete -F _ollama ollama


# [[HUMAN COMMENTED-OUT]]
#This script defines a Bash completion function `_ollama()` that is triggered when the user types "ollama run". It properly handles model names containing colons and ensures robust parsing of data retrieved from the `ollama list` command. The script also correctly filters completions based on the current input and uses safe methods to prevent unexpected behavior. Finally, it restores the original value of `COMP_WORDBREAKS` before exiting, as required by best practices in Bash completion scripting.

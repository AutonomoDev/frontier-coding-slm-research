#!/bin/bash

# Description: Bash completion script for ollama run command.
# Handles model names containing colons.

# Source the bash-completion library.
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /usr/lib/bash-completion/bash_completion ]; then
    . /usr/lib/bash-completion/bash_completion
fi

# Helper function to get words by reference.  This handles cases where it's unavailable.
_get_comp_words_by_ref() {
    if declare -f _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref "$@"
        return
    }
    # Fallback for older bash versions
    local -n ref=$1
    local cur prev words cword
    words=("$@")
    cword=$2
    cur="${words[$((cword - 1))]}"
    prev="${words[$((cword - 1))]}"
    echo "$cur $prev"
}


# Function to complete ollama run command.
_ollama_run_completion() {
    local cur prev words cword run_index models

    # Save and restore COMP_WORDBREAKS
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Find the index of "run" in the COMP_WORDS array.
    run_index=0
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete when the cursor is after "run".
    if [[ "$COMP_CWORD" -eq "$run_index" + 1 ]]; then

        # Retrieve the list of models from ollama list.
        # Robustly handles whitespace.
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # If no models are found, clear COMPREPLY.
        if [[ -z "$models" ]]; then
            COMPREPLY=()
            return 0
        fi

        # Complete based on the current word. Safe prefix matching.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

    else
        COMPREPLY=()  # Clear COMPREPLY when not completing.
    fi

    # ALWAYS restore COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}


# Register the completion function.
complete -F _ollama_run_completion ollama


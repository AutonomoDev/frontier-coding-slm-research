#!/bin/bash
# This bash completion function provides dynamic completions for the command:
#   ollama run <model>
#
# It only triggers when "ollama run" is used, and it dynamically retrieves the list
# of available models by running "ollama list". The output is then filtered based on the
# current word (the user's partial input) and sorted alphabetically using only bash built‐ins.
#
# Installation:
#   • Save this file as ~/.bash_completion.d/ollama_completion.sh or in /etc/bash_completion.d/
#     (depending on your system configuration).
#   • Ensure that your .bashrc sources the directory; for example, add:
#         if [ -d /etc/bash_completion.d ]; then
#             for f in /etc/bash_completion.d/*; do
#                 [ -r "$f" ] && . "$f"
#             done
#         fi
#   • For immediate activation, source the file:
#         source ~/.bash_completion.d/ollama_completion.sh

_ollama_run_completion() {
    # Retrieve the current partial word (the model name so far)
    local cur=${COMP_WORDS[2]}

    # Only provide completions if the command is "ollama run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Capture the output of 'ollama list' into a variable.
    # Redirect stderr to /dev/null so that errors are handled gracefully.
    local model_list
    model_list=$(ollama list 2>/dev/null)

    # If 'ollama list' fails or returns no data, exit silently (no completions)
    if [ -z "$model_list" ]; then
        return 0
    fi

    # Split the output into an array.
    # Save original IFS and set it to newline so that splitting works correctly.
    local old_ifs="$IFS"
    IFS=$'\n'
    mapfile -t models < <(echo "$model_list")
    IFS="$old_ifs"

    # Filter models: add a model to the matches array if its name starts with the current prefix.
    local matches=()
    for m in "${models[@]}"; do
        if [[ "$m" == $cur* ]]; then
            matches+=("$m")
        fi
    done

    # Sort the filtered matches alphabetically using a simple bubble sort (using only built-in comparisons).
    local n=${#matches[@]}
    local swapped=true
    while $swapped; do
        swapped=false
        for (( i=0; i<n-1; i++ )); do
            if [[ "${matches[i]}" > "${matches[$((i+1))]}" ]]; then
                # Swap the two elements.
                tmp="${matches[i]}"
                matches[i]="${matches[$((i+1))]}"
                matches[$((i+1))]="$tmp"
                swapped=true
            fi
        done
    done

    # Populate the COMPREPLY array with sorted completions.
    COMPREPLY=("${matches[@]}")
}

# Register the completion function for the "ollama" command.
complete -F _ollama_run_completion ollama

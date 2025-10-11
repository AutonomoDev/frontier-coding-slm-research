#!/bin/bash

# Load completion helper functions
if [ -n "$BASH_VERSION" ]; then
    # BASH 3.2+
    shopt -s progcomp
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    # BASH 4.1+
    source /usr/share/bash-completion/bash_completion
else
    echo "ERROR: bash completion helper not found." >&2
fi

# Save and restore COMP_WORDBREAKS in ALL code paths
local old_wb="$COMP_WORDBREAKS"
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

# Get the index of "run" in COMP_WORDS array
run_index=$((${COMP_CWORD}-1))

# Only trigger completion when COMP_CWORD == run_index + 1
if [[ ${COMP_WORDS[${run_index}]} == "run" ]]; then
    # Get model names from ollama list output
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Filter and save completions to COMPREPLY array
    COMPREPLY=($(compgen -W "$models" -- "${COMP_WORDS[${run_index}]}"))
fi

# Restore COMP_WORDBREAKS before returning
COMP_WORDBREAKS="$old_wb"

# [[HUMAN COMMENTED-OUT]]
#This script should work for most Bash versions, including those that don't have the `bash-completion` package installed. However, if you want to use this script on a system where `bash-completion` is not available, you may need to modify it slightly to include the necessary completion helper functions directly in the script.


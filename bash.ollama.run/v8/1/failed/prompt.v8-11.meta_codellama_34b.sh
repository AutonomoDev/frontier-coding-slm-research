# [[HUMAN COMMENTED-OUT]]
#Here is a sample Bash completion script for the `ollama run` command that handles model names containing colons:

#!/bin/bash

# Save and restore COMP_WORDBREAKS in all code paths
local old_wb="$COMP_WORDBREAKS"
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

# Define function to get the current word
_get_comp_words_by_ref() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
}

# Get the index of "run" in COMP_WORDS
run_index=$((${#COMP_WORDS[@]} - 1))

# Check if the current word is "run" and if we're at the right position
if [ "${COMP_WORDS[${#COMP_WORDS[@]}]}" != "run" ]; then
    return 0
fi
if [ "$cur" == "run" ] && [ "$prev" != "ollama" ]; then
    # If we're not at the right position, return without setting COMPREPLY
    return 1
fi

# Get a list of all models and filter out ones that don't match the current word
models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep "^$cur")
COMPREPLY=($(compgen -W "$models" -- "$cur"))

# Restore COMP_WORDBREAKS and return
COMP_WORDBREAKS="$old_wb"

# [[HUMAN COMMENTED-OUT]]
#The script first saves and restores `COMP_WORDBREAKS` to remove the colon from the word breaks. It then defines a function to get the current word and checks if it's "run". If it is, it filters out models that don't match the current word using `ollama list` and `awk`. Finally, it sets `COMPREPLY` to the filtered list of models and restores `COMP_WORDBREAKS` before returning.
#
#Note that this script assumes that `ollama list` returns a list of model names with the first column being the name of the model. If your version of `ollama list` has a different format, you may need to modify the script accordingly.


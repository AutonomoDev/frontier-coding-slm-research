#!/bin/bash

# Thinking...
# We need to output the Bash code as specified. Just code, with comments. Let's craft it.
# 
# Define function _ollama_completions. Inside:
# 
# ```
# _local_wk
# ```
# 
# Use local variables.
# 
# Need to capture COMP_WORDS[1] and check "run". If not, return.
# 
# Also need to capture original COMP_WORDBREAKS: local orig_worbreaks=$COMP_WORDBREAKS
# 
# Then modify COMP_WORDBREAKS removing colon.
# 
# Then use _get_comp_words_by_ref -n : cur prev
# 
# After that restore COMP_WORDBREAKS.
# 
# Then if [[ $prev == "run" ]]; then get models.
# 
# Use:
# 
# ```
# models=$(ollama list | awk 'NR>1 {print $1}')
# ```
# 
# Then set COMPREPLY=( $(compgen -W "$models" -- "$cur") )
# 
# But compgen output array, can do:
# 
# ```
# COMPREPLY=( $(compgen -W "$models" -- "$cur") )
# ```
# 
# Should quote models variable properly. Use "$models".
# 
# Ensure compgen used with --.
# 
# Finally register: complete -F _ollama_completions ollama
# 
# Add comments accordingly.
# 
# Make sure local variable names unique.
# 
# Let's produce code.
# ...done thinking.

# Bash completion for `ollama run` that handles model names containing colons
# This script must be sourced after the bash-completion framework is loaded
# The function `_ollama_completions` will be registered to provide completions for the `ollama` command

_ollama_completions() {
    # Ensure we only handle the `ollama run` subcommand
    # COMP_WORDS[1] contains the first argument after `ollama`
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return  # Exit early if not `run`
    fi

    # ----- Handle colon in word breaks -----
    # Save the original word-break characters to restore them later
    local orig_worbreaks=$COMP_WORDBREAKS

    # Temporarily remove the colon from the word-break set so that colons are not treated as separators
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with the modified word-breaks
    # `-n :` tells `_get_comp_words_by_ref` to treat colons as part of words
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word-break set immediately after parsing
    COMP_WORDBREAKS=$orig_worbreaks

    # ----- Completion logic for model names -----
    # If the previous word is `run`, provide model name completions
    if [[ $prev == "run" ]]; then
        # Retrieve the list of models from `ollama list`, skipping the header line
        # The first column contains the model name (which may include colons)
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate the completion replies based on the current word (`cur`)
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

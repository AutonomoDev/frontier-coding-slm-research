#!/bin/bash
# This is a Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names when a user types `ollama run ` and presses the `<TAB>` key.
# The script must parse the output of `ollama list` to extract model names from the first column.
# It also handles colons in model names by temporarily removing them from `COMP_WORDBREAKS`.
# Contextual filtering is applied to suggestions based on the current word being typed.
# The script must not fall back to files when no models match, and it ensures unique suggestions using an associative array.

# Save a reference to the original completion functions for `ollama`
# and register our own completion function for the `run` subcommand.
_ollama_original=$(complete -p ollama 2>/dev/null | sed "s/.*-F \\(.*\\) .*/\\1/" | head -n 1)
complete -o nospace -F _ollama_run_completion ollama run

# Our completion function for `ollama run`.
_ollama_run_completion() {
    # Do nothing if the previous word is not `ollama` or `run`.
    local prev=${COMP_WORDS[COMP_CWORD-2]}
    local cur=${COMP_WORDS[COMP_CWORD-1]}
    [[ $prev == ollama && $cur == run ]] || return 0

    # Save the current value of `COMP_WORDBREAKS` and remove `:` from it.
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get the list of available models from `ollama list`.
    local model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Generate suggestions by filtering the model list based on the current word.
    COMPREPLY=($(compgen -W "$model_list" -- "$cur"))

    # Restore `COMP_WORDBREAKS` to its original value.
    COMP_WORDBREAKS=$old_wb
}


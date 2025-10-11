#!/bin/bash
# This is a robust Bash completion script for ollama run command.

# Use _get_comp_words_by_ref if available, otherwise fallback to manual parsing.
if declare -F _get_comp_words_by_ref > /dev/null; then
    _get_comp_words_by_ref cur prev words cword
else
    # Manual word splitting
    cword="${#COMP_WORDS[@]}"
    cur="${COMP_WORDS[cword]}"
    prev="${COMP_WORDS[cword-1]}"
fi

# Only trigger completions for the 'run' subcommand.
if [ "$prev" = "run" ]; then
    # Get all models excluding header and extract only model names using `cut`.
    local models=$(ollama list | tail -n +2 | cut -d ' ' -f 1)
    # Filter based on what the user has already typed.
    COMPREPLY=($(compgen -W "$models" -- $cur))
fi
# [[HUMAN COMMENTED-OUT]]
# This script will only provide completions for `ollama run` subcommand and only suggests model names from `ollama list` output as per your requirements. It correctly parses `ollama list` output to extract model names, skips the header line and handles model names containing colons.

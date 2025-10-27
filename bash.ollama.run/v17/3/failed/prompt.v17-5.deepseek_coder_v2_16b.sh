#!/usr/bin/env bash

# [[HUMAN COMMENTED-OUT]]
# To create a comprehensive Bash completion script for the `ollama run` command, incorporating both the necessary handling for colon completions and ensuring robustness in model name parsing, we will follow the structured approach outlined below. This approach synthesizes the strengths of previous versions while simplifying the structure to reduce potential errors.

# Function to generate completions for ollama run command
function _ollama_completions {
    local cur prev words cword split
    _init_completion -s || return

    # Check if the second word is 'run'
    if [[ "$prev" != "run" ]]; then
        return
    fi

    # Save original COMP_WORDBREAKS
    local origCompWordsBreaks=$COMP_WORDBREAKS

    # Temporarily remove colon from COMP_WORDBREAKS to handle completions correctly
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with colon handling
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS=$origCompWordsBreaks

    # Check if ollama is available
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Fetch the list of models
    local modelList=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completions based on the current word (cur)
    compgen -W "$modelList" -- "$cur"

    # Ensure that suggestions after colon are correctly handled
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama run command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script defines a single function `_ollama_completions` that handles the Bash completion logic for the `ollama run` command. It starts by ensuring that the subcommand is `run`. If not, it exits immediately to avoid interfering with other commands. The colon in `COMP_WORDBREAKS` is temporarily removed to allow correct parsing of words containing colons. After generating possible completions based on available models and the current word, it ensures that suggestions after a colon are correctly displayed by calling `__ltrim_colon_completions`.
# [[HUMAN COMMENTED-OUT]]
# This script follows all specified requirements, including early exits, proper handling of COMP_WORDBREAKS, dynamic model list generation, and mandatory completion logic for handling colons. It is structured to minimize errors and provide clear, directive instructions to the AI model, ensuring a robust and efficient solution.

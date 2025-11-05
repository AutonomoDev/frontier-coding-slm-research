#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# The following Bash function provides completion for the `ollama` command. This script assumes that the ollama command is correctly installed and configured in your environment, and uses the `__ltrim_colon_completions` and `_get_comp_words_by_ref` functions which are built-in in bash version 4.0 and newer:

_ollama_completions() {
    # Validate command
    [[ "${COMP_WORDS[0]}" != "ollama" ]] && return

    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check for ollama command availability
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Fetch models
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions for the second word
    if [[ $COMP_CWORD == 1 ]]; then
        COMPREPLY=($(compgen -W "serve create show run stop pull push signin signout list ps cp rm help" -- "$cur"))
    # Generate completions for model names
    else
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Make sure to copy and paste this function into your `.bashrc` or equivalent configuration file to make it available in your current shell session. If you want to make it system-wide, you may need to add it to `/etc/bash_completion.d/`.
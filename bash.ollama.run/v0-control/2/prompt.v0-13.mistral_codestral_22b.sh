#!/usr/bin/env bash

# Bash completion function for ollama run command
_ollama_run() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$(ollama list | awk 'NR>1{print $1}' 2>/dev/null)" -- "${current_word}"))
}

# Register the completion function with bash-completion
complete -F _ollama_run ollama_run

# [[HUMAN COMMENTED-OUT]]
# To install this script, save it to a file (e.g., `/etc/bash_completion.d/ollama_run`) and ensure it's sourced in your Bash shell configuration (`.bashrc`, `.bash_profile`, etc.) with the line:
[[ -f /etc/bash_completion.d/ollama_run ]] && . /etc/bash_completion.d/ollama_run
# [[HUMAN COMMENTED-OUT]]
# Then, restart your shell or run `source ~/.bashrc` to apply the changes.

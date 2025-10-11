#!/usr/bin/env bash
_ollama() {
    local cur prev words cword
    _init_completion || return

    if [[ "${prev}" == "run" ]]; then
        # Get model names dynamically by parsing 'ollama list' output
        mapfile -t COMPREPLY < <(compgen -W "$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')" -- "${cur}")
    fi
} && complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# ## Installation
# To install the script, save it to a file (e.g., `/etc/bash_completion.d/ollama`), then source this file in your shell configuration (e.g., `~/.bashrc` or `~/.zshrc`) and restart your terminal session:
# source /etc/bash_completion.d/ollama

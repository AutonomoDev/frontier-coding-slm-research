#!/usr/bin/env bash
_ollama() {
    local cur prev words cword
    _init_completion || return

    # Get the list of models from 'ollama list' command and strip off the header
    COMPREPLY=($(compgen -W "$(ollama list 2>/dev/null | sed 1d | awk '{print $1}')" -- "${cur}"))
    return 0
} && complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation:
# [[HUMAN COMMENTED-OUT]]
# 
# [[HUMAN COMMENTED-OUT]]
# Save the script as `/etc/bash_completion.d/ollama`. To use this script, make sure your shell configuration (e.g., .bashrc or .bash_profile) is set up to load these completions. This usually involves adding a line like `if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi` to the end of your shell configuration file. After saving and reloading your shell, you should see tab completion for `ollama run <model>`.
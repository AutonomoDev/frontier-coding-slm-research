#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# Here's a Bash completion script for `ollama run`:

# bash-completion functions usually use this guard
_ollama_run_completion() {
    local IFS=$'\n'   # Set Internal Field Separator to newline

    # Use compgen, an built-in command for generating completions, to generate
    # completions based on the output of `ollama list` (silently error if it fails)
    COMPREPLY=($(compgen -W "$(ollama list 2>/dev/null)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama run

# [[HUMAN COMMENTED-OUT]]
# Installation instructions:
# 1. Drop this script into your Bash completions directory (usually something like `/etc/bash_completion.d/` or `~/.local/share/bash-completion/`).
# 2. If you've installed it as a file like `/etc/bash_completion.d/ollama`, you can source it in your `.bashrc` or similar by adding the line:
#     . /path/to/your/script
# 3. Start a new terminal session to activate the changes (or run `source ~/.bashrc` for most setups).

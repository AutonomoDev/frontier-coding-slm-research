#!/bin/bash
_ollama_run() {
    local cur prev models completions
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Filter available models based on current prefix
    models=$(ollama list | awk -F' ' '{print $1}')
    completions=("${models[@]}")
    
    COMPREPLY=( $(compgen -W "${completions[*]}" -- ${cur}) )
    return 0
}
complete -F _ollama_run ollama run

# Installation instructions:
# 1. Save the script to a file (e.g., /usr/local/share/bash-completion/_ollama)
# 2. Source the script in your bash startup files (e.g., ~/.bashrc or /etc/bash.bashrc)
```
This script uses Bash's built-in completion system to provide suggestions for `ollama run` based on available models returned by `ollama list`. It does not rely on any external dependencies, including jq or other third-party tools.

To install the script, save it to a file (e.g., `/usr/local/share/bash-completion/_ollama`) and source it in your bash startup files (e.g., `~/.bashrc` or `/etc/bash.bashrc`). For example:
```bash
# ~/.bashrc
source /usr/local/share/bash-completion/_ollama
```


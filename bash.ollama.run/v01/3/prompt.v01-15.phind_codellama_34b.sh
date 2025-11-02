```bash
# Bash completion for "ollama run"
# This script assumes that 'ollama list' prints model names one per line (or separated by whitespace) 
# when run with no formatting flags and 'ollama' is in the $PATH

_ollama_completion() {
    local IFS=$'\n'       # set word separator to newline
    local cur=${COMP_WORDS[COMP_CWORD]}
    local models=$(ollama list 2>/dev/null) || return 0   # ignore errors, silently return no completions
    
    # filter models by prefix
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

complete -o default -F _ollama_completion ollama

# Installation/Activation:
# 1. Drop this script into your bash-completion script directory (e.g., /etc/bash_completion.d/)
# 2. Either restart your terminal or source the script directly in the current shell with ". /path/to/this/script"
```


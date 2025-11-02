# [[HUMAN COMMENTED-OUT]]
# Here is a Bash completion script for `ollama run`:

_ollama_completion() {
    # If the word where the completion was requested for is not the first one
    # and also not the second one (i.e. it's not immediately after `ollama`), then return
    if [ "$COMP_CWORD" -gt 2 ]; then
        return
    fi

    # Obtain models via `ollama list`. If it fails, fail gracefully and return no completions
    local IFS=$'\n'
    local models
    if ! models=$(ollama list 2>/dev/null); then
        return
    fi

    # Filter the model names by the current word prefix
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}
complete -F _ollama_completion ollama

# [[HUMAN COMMENTED-OUT]]
# Installation:
# 
# 1. Save this script to a file named `_ollama`, in your `bash_completion.d` directory (usually `/etc/bash_completion.d` or `$XDG_CONFIG_HOME/bash_completion`). 
# 2. If you've placed the file in `/etc/bash_completion.d`, restart your terminal, otherwise, run `source $XDG_CONFIG_HOME/bash_completion/_ollama` to activate it immediately.
# 
# Note: For this script to work, Bash completion needs to be installed and enabled in your shell environment.
# ollama_run.bash

# Usage: source this file in your .bashrc or .bash_profile, then run `complete -F _ollama_run ollama run`

_ollama_list() {
    # Capture the output of 'ollama list' and store it in a variable
    local models=$(ollama list 2>/dev/null)
    
    if [[ -n $models ]]; then
        # Split the output into lines
        while IFS= read -r line; do
            echo "$line"
        done <<< "$models"
    fi
}

_ollama_run() {
    local cur prev words cword
    _init_completion -s || return

    if [[ $cword -eq 2 ]]; then
        # Get the list of models and complete against it
        COMPREPLY=($(compgen -W "$(_ollama_list)" -- "$cur"))
    fi
}

complete -F _ollama_run ollama run

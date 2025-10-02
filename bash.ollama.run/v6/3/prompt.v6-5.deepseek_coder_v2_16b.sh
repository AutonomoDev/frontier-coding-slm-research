 ```bash
# This is a self-contained Bash completion script for the `ollama run` command.
# It provides autocompletion suggestions for model names.

_ollama_run_completion() {
    local cur prev words cword split
    _init_completion -s || return

    # Check if the previous word is 'run' and the first word is 'ollama'.
    if [[ ${prev} != "run" ]] || [[ ${words[1]} != "ollama" ]]; then
        COMPREPLY=()
        return
    fi

    # Get the list of local models using `ollama list`.
    local models=$(ollama list | tail -n +2 | cut -d' ' -f1)

    # Filter suggestions based on the current word being typed.
    COMPREPLY=($(compgen -W "${models}" -- ${cur}))
}

complete -F _ollama_run_completion ollama run
```


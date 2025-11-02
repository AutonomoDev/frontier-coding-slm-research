 ```bash
# ollama-run.bash

_ollama_run() {
    local cur prev words cword
    _init_completion -s || return

    if [[ ${cur} == -* ]]; then
        # Complete options here if necessary
        COMPREPLY=()
        return 0
    fi

    # Get the list of models from `ollama list` and filter by current prefix
    local models=$(ollama list 2>/dev/null)
    if [ $? -eq 0 ]; then
        COMPREPLY=($(compgen -W "${models}" -- ${cur}))
    else
        COMPREPLY=()
    fi
}

complete -F _ollama_run ollama run
```

### Installation Instructions:
1. Save the script to a file, e.g., `/etc/bash_completion.d/ollama-run.bash` or `~/.bash_completion`.
2. Source the script in your `.bashrc`, `.profile`, or equivalent initialization file:
   ```sh
   source /etc/bash_completion.d/ollama-run.bash
   # or
   source ~/.bash_completion
   ```
3. Restart your shell or source the relevant file again to activate the completion.


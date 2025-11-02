```bash
#!/bin/bash

_ollama_run_completion() {
    local cur prev models

    # Grab the current word being completed (model name) from $COMP_WORDS and $COMP_CWORD
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # Exit if the previous command is not "run"
    [[ $prev != run ]] && return 0

    # Invoke "ollama list" and store its output in a variable (models)
    models=$(ollama list) || return 0

    # Filter model names by prefix, using the current word being completed as the filter
    COMPREPLY=($(compgen -W "$(echo $models | awk '{print $1}')" -- ${cur}))

    # Sort and assign final completions to COMPREPLY
    COMPREPLY=( $(echo ${COMPREPLY[@]} | tr ' ' '\n' | sort) )
}

# Wire the bash-completion function to "ollama"
complete -F _ollama_run_completion ollama
```
Installation instructions:
1. Save the script above to a file (e.g., `ollama-run-completion.sh`).
2. Open your `.bashrc` or equivalent and add the following line at the bottom:
```bash
source /path/to/ollama-run-completion.sh
```
3. Reload your terminal session or run `source ~/.bashrc` to activate the completion script immediately.


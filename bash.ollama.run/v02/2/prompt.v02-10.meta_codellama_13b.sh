 ```bash
#!/bin/bash

_ollama_run() {
    # Only offer completions when command is "ollama run" and user is completing after "run".
    if [[ $COMP_LINE != *"ollama run "* ]] || (( COMP_CWORD > 1 )); then
        return
    fi

    # Invoke `ollama list` once and capture its full output into a variable.
    local -r models=$(ollama list)

    # Use the current word being completed to filter model names so only those matching the prefix are suggested.
    local -a matches=()
    for m in ${models[@]}; do
        if [[ $m == *"$COMP_LINE"* ]]; then
            matches+=($m)
        fi
    done

    # Populate COMPREPLY correctly using compgen or manual filtering.
    local -a sorted=()
    for m in ${matches[@]}; do
        if [[ $m != *"$COMP_LINE"* ]]; then
            continue
        fi
        sorted+=($m)
    done

    COMPREPLY=($(compgen -W "${sorted[*]}" -- "$cur"))
}
complete -F _ollama_run ollama
```


#!/bin/bash
_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(ollama list)
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    COMPREPLY=( $(compgen -W "$opts" -- $cur) )
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama -o default ollama



#! /usr/bin/env bash

_ollama_run_completion() {
    local cur prev words cword
    if ! _get_comp_words_by_ref -n :cur; then
        compgen -W "$(ollama list | tail -n +2 | cut -d' ' -f1)" -- "$cur"
    fi
}

complete -F _ollama_run_completion ollama run

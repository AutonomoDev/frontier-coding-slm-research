#!/bin/bash
# This is a bash completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies.
# Assumes that `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags.

_list_models() {
    local IFS=$'\n'
    local models="$(ollama list)"
    COMPREPLY=( $(compgen -W "$(echo "$models" | awk '{print $1}')") )
}

complete -F _list_models ollama run
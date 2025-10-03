#!/bin/bash
_ollama_run() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi
    local -a model_names=()
    local -i i=0
    while read -r line; do
        if [[ "$line" == *[!\ ]* && "$line" != "#"* && $i -gt 3 ]]; then
            model_names+=("${line%%\ **}")
        fi
        ((i++))
    done < <(ollama list)
    COMPREPLY=($(compgen -W "${model_names[*]}" -- "$cur"))
}
complete -F _ollama_run ollama

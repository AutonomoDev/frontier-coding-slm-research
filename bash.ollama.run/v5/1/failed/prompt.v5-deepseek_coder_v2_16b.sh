#! /usr/bin/env bash

if [[ "${COMP_WORDS[1]}" != "run" ]]; then
    return 0
fi

local cur prev words cword
_get_comp_words_by_ref -n : cur prev words cword || {
    local i=${#COMP_WORDS[@]}-1
    while [ $i -gt 0 ]; do
        case "${COMP_WORDS[i]}" in
            run) break ;;
            *) ((i--)) ;;
        esac
    done
    cword=$((i-1))
    cur="${COMP_WORDS[cword]}"
}

local model_list=$(ollama list | awk 'NR>1 {print $1}')
local IFS=$'\n'
local suggestions=($(compgen -W "${model_list}" -- "$cur"))

# Remove duplicates
local unique_suggestions=()
for suggestion in "${suggestions[@]}"; do
    if [[ ! " ${unique_suggestions[*]} " == *" $suggestion "* ]]; then
        unique_suggestions+=("$suggestion")
    fi
done

COMPREPLY=("${unique_suggestions[@]}")
return 0


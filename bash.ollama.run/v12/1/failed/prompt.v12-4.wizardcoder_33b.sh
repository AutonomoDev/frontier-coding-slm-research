#!/bin/bash
_ollama_completions() {
    local cur prev models matches sorted_matches
    COMPREPLY=()
    
    if  ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    if [[ ${prev} != "run" || ${COMP_WORDS[0]} != "ollama" ]]; then 
        return
    fi

    if ! command -v ollama &> /dev/null; then
        return
    fi
    
    while IFS= read -r line ; do
        model=$(echo $line | awk '{print $1}') # get the first column (model name)
        [[ -z "$model" ]] && continue # skip empty lines and header
        models+=("$model")
    done < <(ollama list 2>/dev/null | tail -n +2)
    
    if (( ${#models[@]} == 0 )); then
        return
    fi
    
    for model in "${models[@]}"; do
        [[ "$model" == "$cur"* ]] && matches+=("$model")
    done
    
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
    
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama

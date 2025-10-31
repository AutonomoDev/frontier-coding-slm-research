_ollama_completions() {
    # Check if command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Fetch models from ollama list, handling empty/missing command
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions and handle colons
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    if (( ${#COMPREPLY[@]} )); then
        COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
        __ltrim_colon_completions "$cur"
    else
        COMPREPLY=()
    fi
}

complete -F _ollama_completions ollama


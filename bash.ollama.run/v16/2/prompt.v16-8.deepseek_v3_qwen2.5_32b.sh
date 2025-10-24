_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

    # Check if ollama available and extract models (skip header, get names only)
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Generate completions and handle colons
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    __ltrim_colon_completions "$cur"
}

# Register completion function for ollama command
complete -F _ollama_completions ollama

# Bash completion script for `ollama run` command
_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}
    # Now cur/prev are correct (e.g., cur="codellama:13", prev="run")

    # Check if ollama available
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Generate completions based on available models
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    # Fix display after colons
    __ltrim_colon_completions "$cur"
    return 0
}

complete -F _ollama_completions ollama
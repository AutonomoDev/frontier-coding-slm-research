# Bash completion for `ollama run` command
# Handles model names containing colons correctly by temporarily modifying COMP_WORDBREAKS

_ollama_completions() {
    local cur prev words cword
    # Use _get_comp_words_by_ref if available (bash-completion v2+)
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Fallback for older versions; manually parse words
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # The core issue: Bash splits on ':' by default, breaking completion for models like "codellama:13b"
    # Solution: Temporarily remove ':' from COMP_WORDBREAKS to prevent splitting on colons
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse current and previous words without treating ':' as a word separator
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    fi
    
    # Restore original word breaks immediately
    COMP_WORDBREAKS=${_old_wb}

    # Only complete after "ollama run"
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

complete -F _ollama_completions ollama

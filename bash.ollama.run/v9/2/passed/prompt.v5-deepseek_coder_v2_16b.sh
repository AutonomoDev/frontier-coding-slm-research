# Bash completion script for the `ollama run` command
_ollama_completions() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur:prev:words:cword

    # Save the original word break characters
    local _old_wb=${COMP_WORDBREAKS}
    # Modify COMP_WORDBREAKS to remove the colon
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # Use the helper to re-parse and correctly set `cur` and `prev`
    _get_comp_words_by_ref -n : cur prev
    # Restore the original word breaks immediately
    COMP_WORDBREAKS=${_old_wb}

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

complete -F _ollama_completions ollama


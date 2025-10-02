_ollama_completions() {
    # Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}

    # Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Use the helper to re-parse and correctly set `cur` and `prev`.
    # The `-n :` option tells it to NOT use the colon as a separator.
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion with `complete -F _ollama_completions ollama`.
complete -F _ollama_completions ollama


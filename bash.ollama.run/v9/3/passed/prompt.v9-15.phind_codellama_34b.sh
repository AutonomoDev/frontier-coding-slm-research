#!/bin/bash
# Bash completion for the `ollama` command.
# Requires bash-completion v2 or later.

_ollama_completions() {
    # Temporarily remove colon from word break characters.
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with our new rule.
    if ! _get_comp_words_by_ref -n : cur prev; then
        return 1
    fi

    # Restore original word break characters.
    COMP_WORDBREAKS=${_old_wb}

    # If the previous word is `run`, we want to complete model names.
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
} &&
# Register the completion function for `ollama`.
complete -F _ollama_completions ollama

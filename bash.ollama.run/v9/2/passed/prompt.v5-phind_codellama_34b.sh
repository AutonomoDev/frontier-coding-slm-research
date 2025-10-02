#!/bin/bash
# This is a Bash completion script for the `ollama run` command.
# It dynamically completes model names retrieved from the `ollama list` command.

_ollama_completions() {
    # Core logic: handle arguments containing colons correctly by re-parsing `cur` and `prev`.

    local _old_wb=${COMP_WORDBREAKS}  # Save original word break characters.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}  # Modify to remove colon as a word break.
    _get_comp_words_by_ref -n : cur prev  # Re-parse command line with new rule.
    COMP_WORDBREAKS=${_old_wb}  # Restore original word breaks immediately.

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

complete -F _ollama_completions ollama  # Register the completion function.


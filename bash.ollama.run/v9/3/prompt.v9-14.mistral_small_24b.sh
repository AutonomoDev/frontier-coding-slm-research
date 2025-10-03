#!/bin/bash

# Function to handle completions for the `ollama run` command.
_ollama_completions() {
    # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
    # makes the previous word "codellama" and the current word an empty string.
    # This breaks our context logic for completing model names.

    # THE SOLUTION: We temporarily remove ':' from the word-breaking characters
    # and use a helper function to re-parse the command line with our new rule.

    # 1. Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}

    # 2. Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
    #    The `-n :` option tells it to NOT use the colon as a separator.
    _get_comp_words_by_ref -n : cur prev

    # 4. Restore the original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function with the `ollama` command.
complete -F _ollama_completions ollama

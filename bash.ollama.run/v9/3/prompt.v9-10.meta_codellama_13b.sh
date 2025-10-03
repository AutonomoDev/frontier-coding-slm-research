#!/bin/bash

_ollama_completions() {
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
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a completion function `_ollama_completions` that is registered with the `complete` command to handle completions for the `ollama run` subcommand. The function first saves the original value of `COMP_WORDBREAKS`, modifies it to remove colons, and then uses the `_get_comp_words_by_ref` helper function to re-parse the current and previous words with the updated word breaks. Finally, it restores the original `COMP_WORDBREAKS` value and completes the list of available model names based on the output of `ollama list`.
#
#The script uses a single helper function to perform both the parsing and completion logic, which makes it more robust and reusable in other contexts. The `_get_comp_words_by_ref` helper function is used to correctly set the `cur` and `prev` variables, even when a colon is typed as part of the command line.
#
#The script should be saved to a file with a `.sh` extension and sourced or executed to enable the completion functionality.


# [[HUMAN COMMENTED-OUT]]
#Here is the complete Bash completion script for the `ollama` command with advanced completion for non-standard word breaks:

#!/bin/bash

_ollama_completions() {
    # Save the original word break characters
    local _old_wb=${COMP_WORDBREAKS}

    # Modify COMP_WORDBREAKS to remove the colon
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Use the helper function to re-parse and correctly set `cur` and `prev`
    _get_comp_words_by_ref -n : cur prev

    # Restore the original word breaks immediately to avoid side-effects
    COMP_WORDBREAKS=${_old_wb}

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion with `complete`
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
#In this script, we define a function `_ollama_completions` that will be called by the Bash completion framework when the user types `ollama run`. This function first saves the original word break characters in `_old_wb`, then modifies `COMP_WORDBREAKS` to remove the colon and use it as a word break.
#
#Next, we call the helper function `_get_comp_words_by_ref` with the `-n :` option to re-parse the command line with our new rule. This ensures that `cur` and `prev` are correctly set, even when colons are used as word breaks.
#
#Finally, we restore the original `COMP_WORDBREAKS` variable to avoid any side effects, then complete the model names using the `compgen` command and the output of `ollama list`.
#
#We register this completion function with `complete -F _ollama_completions ollama`, which tells Bash to use `_ollama_completions` as the completion function for the `ollama` command.


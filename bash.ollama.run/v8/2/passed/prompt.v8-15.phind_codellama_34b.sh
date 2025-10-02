# [[HUMAN COMMENTED-OUT]]
#Here is a Bash completion script for the `ollama run` command:

#!/bin/bash

_ollama_run() {
    local cur prev words cword model_names

    # Make sure COMP_WORDBREAKS does not include colon.
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Obtain the list of model names.
    model_names=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}') || return

    # Only provide completions when it's the second word and immediately after "run".
    if [[ "$cur" == *: && "$prev" != "run" ]]; then
        COMPREPLY=()
    elif [[ "$cword" -eq 2 ]] && [[ "$prev" == "run" ]]; then
        # Generate completions for the model names.
        COMPREPLY=($(compgen -W "$model_names" -- "$cur"))
    fi

    # Restore original value of COMP_WORDBREAKS.
    COMP_WORDBREAKS="$old_wb"

    return 0
}

complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#You can source this script immediately after creating it to make the completion available in your current shell session. Save this script to a file, then source it with `source /path/to/the/script`. You might want to add this line to your `.bashrc` or `.bash_profile` to make the completion persistent across sessions.
#
#Note: This script is designed for Bash completion version 2 and should work as long as `ollama list` command outputs in the given format and the `ollama` command is available. The script might need adjustments if these conditions are not met.


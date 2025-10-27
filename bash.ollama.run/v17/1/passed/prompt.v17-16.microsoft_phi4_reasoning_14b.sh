# Security Analysis: SAFE - No dangerous operations detected
# This script only performs bash completion operations, no file writes or privilege escalation

#!/bin/bash
# Completion function for the 'ollama' command.
_ollama_completions() {
    # Only complete when the first argument is "run" (i.e., 'ollama run ...').
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Save original COMP_WORDBREAKS so it can be restored later.
    local orig_wordbreaks="$COMP_WORDBREAKS"

    # Remove the colon (:) from COMP_WORDBREAKS to ensure that model names containing colons are parsed correctly.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Re-parse the command line words using _get_comp_words_by_ref with a colon as delimiter.
    # This sets $cur (the current word being completed) and $prev (the previous word).
    _get_comp_words_by_ref -n : cur prev

    # Immediately restore COMP_WORDBREAKS to its original state to avoid side effects.
    COMP_WORDBREAKS="$orig_wordbreaks"

    # Check if the 'ollama' command exists; if not, exit early.
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # Retrieve the list of models from "ollama list", skipping the header line.
    local model_list
    model_list=$(ollama list | awk 'NR > 1 {print $1}')

    # Generate completion suggestions using compgen with the fetched model names.
    COMPREPLY=( $(compgen -W "$model_list" -- "$cur") )

    # Ensure proper display of completions that include colons by calling __ltrim_colon_completions.
    __ltrim_colon_completions "$cur"
}

# Register the _ollama_completions function for bash completion on the 'ollama' command.
complete -F _ollama_completions ollama
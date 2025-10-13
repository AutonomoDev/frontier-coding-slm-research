#!/bin/bash
# Save original COMP_WORDBREAKS and temporarily remove colons so that model names containing colons are handled correctly.
_ollama_run_completions() {
    # Save original word break characters.
    local orig_wb="$COMP_WORDBREAKS"
    # Remove colon from word break list.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    # Re-parse the current and previous words with modified word break settings.
    _get_comp_words_by_ref -n : cur prev
    # Restore original COMP_WORDBREAKS immediately.
    COMP_WORDBREAKS="$orig_wb"

    # Only activate completions when the second argument is "run".
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Dynamically fetch model names from ollama list (skip header).
    local models
    models=$(ollama list | sed '1d' | awk '{print $1}')

    # Generate completion suggestions.
    COMPREPLY=( $(compgen -W "$models" -- "${COMP_WORDS[2]}") )
}

complete -F _ollama_run_completions ollama

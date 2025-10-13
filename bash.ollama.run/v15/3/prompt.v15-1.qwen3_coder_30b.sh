#!/bin/bash

_ollama_run_completions() {
    # Save original COMP_WORDBREAKS
    local orig_comp_wordbreaks="$COMP_WORDBREAKS"

    # Remove ':' from COMP_WORDBREAKS to handle colons in model names
    COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}

    # Re-parse words with updated COMP_WORDBREAKS
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS immediately
    COMP_WORDBREAKS="$orig_comp_wordbreaks"

    # Only activate completion for 'ollama run' subcommand
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Fetch model names from ollama list, skip header, extract first column
        local models
        models=$(ollama list | awk 'NR>1 {print $1}' 2>/dev/null)

        # Generate completions
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completions ollama
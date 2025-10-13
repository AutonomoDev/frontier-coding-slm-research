#!/bin/bash
# This is a Bash completion script for the 'ollama run' command. It dynamically fetches model names from 'ollama list' and correctly handles model names containing colons (e.g., 'codellama:13b').

# Save original COMP_WORDBREAKS, remove colon (:) to avoid splitting at colons
__ollama_orig_comp_wordbreaks="$COMP_WORDBREAKS"
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

_ollama_run_completions() {
    local cur prev
    
    # Use _get_comp_words_by_ref to re-parse current and previous words, using colon as a delimiter
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$__ollama_orig_comp_wordbreaks"

    # Check if the second word (excluding the command itself) is 'run'
    [[ "${COMP_WORDS[1]}" == "run" ]] || return 0

    # Get model names from 'ollama list', excluding header line, and suggest them as completions
    COMPREPLY=( $(compgen -W "$(ollama list --no-trunc | awk 'NR > 1 {print $1}')" -- "$cur") )

    return 0
}

# Register the function for 'ollama' command and its 'run' subcommand completions
complete -F _ollama_run_completions ollama
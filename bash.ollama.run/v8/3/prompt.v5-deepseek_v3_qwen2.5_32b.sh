#!/bin/bash

# Bash completion script for 'ollama run' command.
#
# - Handles model names containing colons (e.g., codellama:13b).
# - Uses robust data parsing and position detection.
# - Preserves COMP_WORDBREAKS integrity to avoid breakage.

_ollama_run_completion() {
    local cur prev words cword old_wb models run_index

    # Detect if helper function is available for better handling
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Fallback to manual extraction when helper isn't available
        local i=0
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[$((COMP_CWORD-1))]}"
    }

    # Find the position of "run" in COMP_WORDS array.
    run_index=-1
    for ((i=0; i < cword; i++)); do
        if [[ "${words[i]}" == "ollama" ]]; then
            ((i += 1))
            if [[ "${words[i]}" == "run" ]]; then
                run_index=$i
                break
            fi
        fi
    done

    # Trigger completion only when 'run' is found and current position is next to it.
    if [[ $cword -eq $((run_index + 1)) && $run_index != -1 ]]; then
        # Preserve COMP_WORDBREAKS to handle colons properly, then restore it later.
        old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:} # Remove colon from word break chars

        # Retrieve model names from 'ollama list' while ignoring empty lines and duplicates.
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Generate completion matches using compgen for safe prefix matching.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        # Restore COMP_WORDBREAKS before any exit or return.
        COMP_WORDBREAKS="$old_wb"
    else
        # Clear COMPREPLY to avoid fallbacks if not in the expected position.
        COMPREPLY=()
    fi
}

# Register completion function for 'ollama run'.
complete -F _ollama_run_completion ollama

# Explanation:
#
# 1. The script checks if the helper function '_get_comp_words_by_ref' is available to extract current word and previous word correctly.
# 2. It locates the position of "run" in the command line arguments array (COMP_WORDS).
# 3. Completion is triggered only when the user is typing after "ollama run".
# 4. COMP_WORDBREAKS is temporarily modified to include colons, allowing tab completion for model names like 'codellama:13b'.
# 5. Model names are fetched from 'ollama list', ensuring robust parsing that can handle varying whitespace.
# 6. compgen is used with -W option for safe prefix matching, avoiding regex issues or special characters in model names.
# 7. COMP_WORDBREAKS is always restored to its original state before any exit or return to prevent side effects elsewhere.
#
# Usage: Source this script (e.g., via .bashrc) and the completion should work as expected for 'ollama run' commands.


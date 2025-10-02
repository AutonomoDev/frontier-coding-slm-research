#!/usr/bin/env bash

_ollama_run() {
    local cur prev cword run_index models old_wb

    # Helper function fallback
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the exact position of "run" in COMP_WORDS array
    for (( i=0; i < ${#words[@]}; i++ )); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when COMP_CWORD is immediately after "run"
    if [ "$cword" -eq $((run_index+1)) ]; then
        old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from COMP_WORDBREAKS

        # Robust data parsing for model names, handling variable whitespace and duplicates
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Safe filtering using compgen's -W option
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

        COMP_WORDBREAKS="$old_wb"  # Restore original COMP_WORDBREAKS value
    fi
}

# Register completion function with command "ollama", but no default filename fallback
complete -F _ollama_run ollama


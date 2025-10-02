#!/usr/bin/env bash

# Ollama run completion script for bash-completion v2
# Completes model names after "ollama run" command
# Handles colon in model names by safely manipulating COMP_WORDBREAKS

__ollama_run() {
    # Get current and previous word
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        # Manual fallback when helper unavailable
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the exact position of "run" in COMP_WORDS array
    local run_index=-1
    for ((i=0; i<=${#words[@]} - 1; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when current word follows "ollama run"
    if [ $cword != $((run_index + 1)) ]; then
        return
    fi

    # Save and restore COMP_WORDBREAKS in ALL code paths
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

    # Retrieve model names via ollama list command and parse output
    # This solution is robust to variable whitespace and duplicate entries
    local models=($(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++'))

    # Safe prefix matching for model completions
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # Restore COMP_WORDBREAKS before ANY return/exit
    COMP_WORDBREAKS="$old_wb"
}

# Register completion function for "ollama run" command with no filename fallback
complete -F __ollama_run ollama


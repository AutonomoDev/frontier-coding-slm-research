#!/bin/bash

_ollama_run() {
    # MUST save and restore COMP_WORDBREAKS in ALL code paths
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

    # Find the exact position of "run" in COMP_WORDS array
    local run_index=$(for i in "${!COMP_WORDS[@]}"; do [[ ${COMP_WORDS[i]} == "run" ]] && echo $i; done)
    if [[ -z $run_index ]]; then return 1; fi

    # Only trigger completion when COMP_CWORD is next to "run"
    local cur="${COMP_WORDS[$((COMP_CWORD+1))]}"
    local prev="${COMP_WORDS[${COMP_CWORD-1}]}"

    # Get list of available models from `ollama list` command
    if ! _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
        # Manual fallback when helper unavailable
        local old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
    fi
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # PREFERRED: Safe prefix matching
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # ALWAYS restore before ANY return/exit
    COMP_WORDBREAKS="$old_wb"
}

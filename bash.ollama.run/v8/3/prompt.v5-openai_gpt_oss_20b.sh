#Thinking...
#We need to write a bash completion script for "ollama run" that handles colons in
# model names. Must handle COMP_WORDBREAKS removal and restoration, find position
# of "run" in COMP_WORDS, only trigger if cur after run. Use _get_comp_words_by_ref
# if available, fallback. Parse models via awk. Then use compgen to produce
# completions. No default fallback. Provide script only with comments starting with
# '#'. Ensure to restore COMP_WORDBREAKS always. Use local variables. Provide
# complete script. Use `complete -F _ollama_run_completion ollama`. Ensure to not
# use -o default. Include comment explaining script. Provide ready to source. Let's
# produce.
#...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run` that correctly handles model names containing colons.
# This script is designed for the Bash Completion framework v2.
#
# Usage:
#   source this_file
#   (or add to your .bashrc)
#
# The completion works only for the `run` subcommand and will provide
# model names from `ollama list` that may include colons.
#
# Important:
#   - COMP_WORDBREAKS is temporarily stripped of ':' to allow colons to be part
#     of a single word. It is restored before any exit.
#   - Position of "run" in COMP_WORDS is detected dynamically; no hard‑coded
#     indices are used.
#   - A fallback implementation is provided if the helper `_get_comp_words_by_ref`
#     is not available.

# ----------------------------------------------------------------------
# Helper function: detect the index of the target subcommand in COMP_WORDS
# ----------------------------------------------------------------------
_ollama_find_subcommand_index() {
    local cmd="$1"
    local idx=0
    while [[ $idx -lt ${#COMP_WORDS[@]} ]]; do
        if [[ "${COMP_WORDS[$idx]}" == "$cmd" ]]; then
            echo "$idx"
            return 0
        fi
        ((idx++))
    done
    echo "-1"  # not found
    return 1
}

# ----------------------------------------------------------------------
# Main completion function for `ollama run`
# ----------------------------------------------------------------------
_ollama_run_completion() {
    local cur prev words cword
    # 1. Retrieve COMP_WORDS/COMP_CWORD safely
    if _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
        :  # helper succeeded
    else
        # Fallback when the helper is not present
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # 2. Find the index of the subcommand "run"
    local run_idx
    run_idx=$(_ollama_find_subcommand_index "run")
    if [[ $run_idx -lt 0 ]]; then
        # No "run" subcommand found; nothing to complete
        COMPREPLY=()
        return
    fi

    # 3. Only complete when the cursor is immediately after "run"
    if [[ $cword -ne $((run_idx + 1)) ]]; then
        COMPREPLY=()
        return
    fi

    # 4. Temporarily remove ':' from word breaks to allow colons in completions
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # 5. Grab model names from `ollama list`
    #    Use awk to skip header and handle variable spacing
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # 6. Generate completions safely using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # 7. Restore the original word breaks before exiting
    COMP_WORDBREAKS="$old_wb"
}

# ----------------------------------------------------------------------
# Register the completion function
# ----------------------------------------------------------------------
complete -F _ollama_run_completion ollama

# End of script


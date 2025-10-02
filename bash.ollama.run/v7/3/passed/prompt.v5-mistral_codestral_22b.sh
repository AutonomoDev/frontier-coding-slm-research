#!/usr/bin/env bash

_ollama_run_completion() {
    # Ensure COMP_WORDS and COMP_CWORD are defined and populated
    if [ ${COMP_CWORD} -lt 2 ] || ! type _get_comp_words_by_ref > /dev/null; then
        cur=${COMP_WORDS[${COMP_CWORD}]}
        prev=${COMP_WORDS[$((COMP_CWORD-1))]}
    else
        # Get current and previous word using the helper function (bash-completion v2+)
        _get_comp_words_by_ref cur prev words cword
    fi

    if [ "${prev}" == "run" ]; then
        # Save original COMP_WORDBREAKS and temporarily remove colon
        old_wb=$COMP_WORDBREAKS
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Run ollama list and parse output (skip header, get first column)
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

        if [ -n "$models" ]; then
            # Filter models based on current word being typed using compgen
            COMPREPLY=($(compgen -W "${models}" -- ${cur}))
            # Ensure uniqueness of suggestions (avoid duplicates)
            mapfile -t COMPREPLY < <(printf '%s\n' "${COMPREPLY[@]}" | awk '!seen[$0]++')
        fi

        # Restore original COMP_WORDBREAKS
        COMP_WORDBREAKS=$old_wb
    fi
}

# Register completion function for ollama run subcommand
complete -F _ollama_run_completion ollama
